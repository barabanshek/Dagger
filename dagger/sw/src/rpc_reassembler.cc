#include "rpc_reassembler.h"

namespace frpc {

RpcReassembler::RpcReassembler(size_t buffer_size, ReorderingType rod_type):
    buffer_size_(buffer_size),
    rod_type_(rod_type) {
    // Allocate entry heap here
    entry_heap_ = new ReassemblyEntry[buffer_size];

    // Mark the whole heap free
    for (size_t i=0; i<buffer_size_; ++i) {
        entry_heap_free_slots_.push(i);
    }
}

RpcReassembler::~RpcReassembler() {
    if (entry_heap_ != nullptr) {
        delete[] entry_heap_;
    }
}

int RpcReassembler::append_to_buffer(const RpcPckt* rpc_packet) {
    assert(rpc_packet->hdr.n_of_frames > 1);

    size_t rpc_id = rpc_packet->hdr.rpc_id;

    if (rpc_packet->hdr.frame_id == 0) {
        // Got head
        // Make head entry and append to heap
        ReassemblyEntry heap_ptr;
        append_to_heap(rpc_packet, heap_ptr);

        // Append to hash table
        auto heads_it = heads_.find(rpc_id);
        if (heads_it != heads_.end()) {
            // Should be a dummy entry here
            assert(heads_it->dummy == true);
            // Modify (fill) it
            modify_in_buffer(*heads_it, heap_ptr);
        } else {
            // Create new reference
            heads_[rpc_id] = heap_ptr;
        }
    } else {
        // Got intermediate entry
        // Append to heap
        ReassemblyEntry* entry_ptr;
        append_to_heap(rpc_packet, entry_ptr);

        // Link entry
        auto head_ptr_it = heads_.find(rpc_id);
        if (head_ptr_it != heads.end()) {
            // We have already seen the head for this entry
            // Just link it in
            ReassemblyEntry* head_ptr = *head_ptr_it;
            if (head_ptr->next == nullptr) {
                // First entry after head
                assert(head_ptr->tail == nullptr);

                head_ptr->next = entry_ptr;
                head_ptr->tail = entry_ptr;
            } else {
                assert(head_ptr->tail != nullptr);
                assert(head_ptr->next != nullptr);

                // Need to find the right place here (i.e. sort while adding)
                // Tail optimization:
                //   - reordering does not happen often
                //   - and it does not happen at all if reliable transport with
                //     a strong NUMA consistency model is used
                //   - it is likely the tail's frame_id is smaller than the
                //     current frame, so check it first
                // Also if reordering is onAccessing, no needs to reorder now
                ReassemblyEntry* tail_ptr = head_ptr->tail;
                assert(tail_ptr->next == nullptr);

                if (rod_type_ == onAccessing ||
                    tail_ptr->payload.hdr.frame_id <
                                                    rpc_packet->hdr.frame_id) {
                    // In order receipt or later reordering, append here
                    tail_ptr->next = entry_ptr;
                    tail_ptr = entry_ptr;
                } else {
                    // Need to find the place
                    ReassemblyEntry* insert_after =
                        get_place_to_insert(head_ptr, rpc_packet->hdr.frame_id);

                    assert(insert_after->next != nullptr);
                    assert(insert_after->next->payload.hdr.frame_id >
                                                    rpc_packet->hdr.frame_id);
                    ReassemblyEntry* insert_before = insert_after->next;

                    insert_after->next = entry_ptr;
                    entry_ptr->next = insert_before;
                }
                
            }

        } else {
            // The head has not arrived yet
            // Just reserve a dummy entry in the heads_
            ReassemblyEntry heap_ptr;
            append_to_heap(nullptr, heap_ptr);
            heads_[rpc_id] = heap_ptr;

            // Link the packet with the dummy entry
            head_ptr->next = entry_ptr;
            head_ptr->tail = entry_ptr;
        }
    }
}

int RpcReassembler::append_to_heap(const RpcPckt* rpc_packet,
                                   ReassemblyEntry* heap_ptr) {
    assert(rpc_packet != nullptr);
    assert(heap_ptr != nullptr);

    if (entry_heap_free_slots_.size() == 0) {
        FRPC_ERROR("Reassembling buffer is full\n");
        return 1;
    }

    size_t slot_id = entry_heap_free_slots_.pop();
    heap_ptr = entry_heap_ + slot_id;

    if (rpc_packet != nullptr) {
        memcpy(heap_ptr->payload, rpc_packet, sizeof(RpcPckt));
        heap_ptr->dummy = false;
        heap_ptr->size = rpc_packet->hdr.argl/64;
        heap_ptr->next = nullptr;
        head_ptr->tail = nullptr;

    } else {
        heap_ptr->dummy = true;
        heap_ptr->size = 0;
        heap_ptr->next = nullptr;
        head_ptr->tail = nullptr;

    }

    return 0;
}

void RpcReassembler::modify_in_buffer(ReassemblyEntry* entry,
                                      const RpcPckt* rpc_packet) {
    assert(entry != nullptr);
    assert(rpc_packet != nullptr);
    assert(entry->next != nullptr);
    assert(entry->tail != nullptr);

    memcpy(entry->payload, rpc_packet, sizeof(RpcPckt));
    heap_ptr->size = rpc_packet->hdr.argl/64;
}

ReassemblyEntry* RpcReassembler::get_place_to_insert(const ReassemblyEntry* head,
                                                     uint8_t frame_id) {
    // The linked list is sorted, so we need to find the right place in a sorted
    // list.
    // Do it with O(n) iteration for now
    // TODO: can we do log(n)?
    assert(head != nullptr);

    ReassemblyEntry* it = head;
    while(head->next != nullptr &&
          head->next->payload.hdr.frame_id < frame_id) {
        it = it->next;
    }

    return it;
}

}  // namespace frpc
