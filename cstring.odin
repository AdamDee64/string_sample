package main

import "core:fmt"
import "core:os"

// some string manipulation in Odin, specifically how to convert an Odin string to a C-string
// there are faster ways to do this but this is a verbose explanation for better understanding and reference

// https://odin-lang.org/docs/overview/#string-type-conversions

main :: proc(){

  // create a regular Odin string.
  o_str : string = "Hello world" 

  // hello world uses characters that come from the ascii table, so the length of the string is 11 bytes even when utf-8 encoded. 
  // if this were a c type string, the length would be 12 to include the null terminator
  fmt.printf("%d - length of the original Odin string\n", len(o_str)) 

  // create an array of bytes. by default Odin will init all bytes to 0. 
  bytes: [32]byte 

  // we copy the byte values of the hello world string to the byte array. 
  // this will change the values of the first 11 bytes and leave the rest as 0
  // https://pkg.odin-lang.org/base/runtime/#copy
  fmt.printf("%d - number of elements copied from string to byte array\n", copy(bytes[:], o_str) )

  // for testing purposes, we will change the last byte of the array to something other than 0
  bytes[31] = '!' 

  // Here are 3 ways to print an array of bytes to the console as a string in Odin. 
  // Notice they skip the 0 values of the array and print the final byte as it was set
  fmt.printf("%s - a string formatted directly from the array of bytes\n", bytes)
  fmt.printf("%s - using the transmute procedure\n", transmute(string)bytes[:]) // https://odin-lang.org/docs/overview/#transmute-operator
  fmt.printf("%s - cast to string from byte array slice\n", string(bytes[:]))

  // to print as a c-string requires an extra step since an Odin string and a c-string are structured and processed differently. 
  // c-strings are read by reading every byte starting at a pointer to the array of bytes, which mimics the char array structure of a string in native C
  // so we need to create a pointer to the array bytes to be read
  ptr : [^]byte = raw_data(bytes[:])

  // now we can cast the byte array data to a cstring.
  // notice that the special character we added at the last byte is NOT printed.
  // this is because c-strings stop reading at the first null terminator, which occurs at the 12th byte in the array
  fmt.printf("%s - printed as a c-string\n", cstring(ptr))

  file_to_string_test()

}

// convert a text file to a c-string. 
// useful for things like loading shaders from a file to an opengl function
file_to_string_test :: proc () {

  file, success := os.read_entire_file("./hello.txt")
  if success {
    fmt.print("as string:", string(file),"\n")
    u8_ptr : [^]u8 = raw_data(file[:])
    fmt.print("as cstring:", cstring(u8_ptr),"\n")
  }

}