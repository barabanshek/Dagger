#
# Dataset generator for kvs service
#

#!/usr/bin/python

import sys

def generate(dataset_filename, num_of_samples, key_length, value_length, key_placeholder, value_placeholder):
	with open(dataset_filename, 'w+') as f:
		f.write(str(key_length) + '\n')
		f.write(str(value_length) + '\n')
		f.write(str(num_of_samples) + '\n')

		for i in range(num_of_samples):
			idx_str = str(i)
			idx_str_len = len(idx_str)

			key_str = key_placeholder * (key_length - idx_str_len)
			key_str = key_str + idx_str

			value_str = value_placeholder * (value_length - idx_str_len)
			value_str = value_str + idx_str

			f.write(key_str + ':' + value_str + '\n')

#
# Main
#
def main():
	generate(sys.argv[1],
		     int(sys.argv[2]),
		     int(sys.argv[3]),
		     int(sys.argv[4]),
		     sys.argv[5],
		     sys.argv[6])

if __name__ == "__main__":
	main()
