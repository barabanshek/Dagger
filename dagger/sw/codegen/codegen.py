#
# Codegenerator for Dagger IDL
#

#!/usr/bin/python

class CodeGen:
	def __init__(self, tmpl_filename = ""):
		self.__code = ""
		self.__seek_ptr = 0

	def append(self, line):
		self.__code = self.__code[:self.__seek_ptr] \
		            + line \
		            + self.__code[self.__seek_ptr:]
		self.__seek_ptr = len(self.__code)

	def append_snippet(self, snippet):
		self.__code = self.__code[:self.__seek_ptr] \
				    + snippet \
		            + self.__code[self.__seek_ptr:]
		self.__seek_ptr = len(self.__code)

	def append_codegen(self, codegen):
		self.__code = self.__code[:self.__seek_ptr] \
		            + codegen.get_code() \
		            + self.__code[self.__seek_ptr:]
		self.__seek_ptr = len(self.__code)

	def append_from_file(self, tmpl_filename):
		with open(tmpl_filename) as tmpl_f:
			self.__code = self.__code[:self.__seek_ptr] \
						+ tmpl_f.read() \
						+ self.__code[self.__seek_ptr:]
			self.__seek_ptr = len(self.__code)

	def replace(self, token, string):
		self.__code = self.__code.replace(token, string)

	def remove_token(self, token):
		self.__code = self.__code.replace(token, '', 1)

	def seek(self, token):
		self.__seek_ptr = self.__code.index(token)

	def get_code(self):
		return self.__code
