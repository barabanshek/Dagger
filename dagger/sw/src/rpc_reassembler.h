#ifndef _RPC_REASSEMBLER_H_
#define _RPC_REASSEMBLER_H_

namespace frpc {

enum ReorderingType {
    onArival,
    onAccessing
};

struct ReassemblyEntry {
    bool dummy;
    size_t size;
    RpcPckt payload;
    ReassemblyEntry* next;
    ReassemblyEntry* tail;
};

class RpcReassembler {
public:
    RpcReassembler(size_t buffer_size, ReorderingType rod_type = onArival);
    ~RpcReassembler();

    int append_to_buffer(const RpcPckt* rpc_packet);
    void modify_in_buffer(ReassemblyEntry* entry, const RpcPckt* rpc_packet);
    ReassemblyEntry* get_place_to_insert(const ReassemblyEntry* head,
                                         uint8_t frame_id) const;

private:
    int append_to_heap(const ReassemblyEntry* rpc_packet,
                       ReassemblyEntry* heap_ptr);

private:
    size_t buffer_size_packets;
    ReorderingType rod_type_;

    std::unordered_map<uint32_t, ReassemblyEntry*> heads_;

    std::queue<ReassemblyEntry*> entry_heap_free_slots_;
    ReassemblyEntry* entry_heap_;

};

}  // namespace frpc

#endif   // _RPC_REASSEMBLER_H_
