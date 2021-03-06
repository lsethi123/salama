# Salama


Salama is about native code generation in and of ruby.

It is probably best to read the book first. 

Currently the work is to get the styetm to bootstrap, ie produce and executable that does what the ruby code says.

Later that executable nneds to extend itself, but to do so cwill be able to use the same code.

## Done

### Assembly

Produce binary that represents code. 
Traditionally called assembling, but there is no need for an external file representation. 

Most instructions are in fact assembling correctly. Meaning i have tests, and i can use objbump to verify the correct assembler code is disasembled

I even polished the dsl and so (from the tests), this is a valid hello world:

    hello = "Hello World\n"
    @program.main do 
      mov r7, 4     # 4 == write
      mov r0 , 1    # stdout
      add r1 , pc , hello   # address of "hello World"
      mov r2 , hello.length
    	swi 0         #software interupt, ie kernel syscall
      mov r7, 1     # 1 == exit
    	swi 0
    end
    write(7 + hello.length/4 + 1 , 'hello') 

### Linking

Package the code into an executable, currently elf, and very simple at that.

Above Hello World can be linked and run. And will say its thing.

There is no way to link c code currently and not planned either, for some time (see next)

### Syscalls

Some small portion of what libc usually provides is needed even right at the beginning.
Mainly file open and read, exit, that kind of thing. Looking at libc implementations and
kernel "api" docs, this is quite simple to do.

As said, "Hello world" comes out and does use syscall 4.
Also the program stops by syscall exit. 
The full list is on the net and involves mostly just work.

### Parse ruby

Parse simple code, using Parslet. This has been seperated out as it's own gem, salama-reader.

Parsing is a surprisingly fiddly process, very space and order sensitive. But Parslet is great and simple
expressions (including function definitions and calls) are starting to work.

I spent some time on the parse testing framework, so it is safe to fiddle and add. 
In fact it is very modular and  so ot is easy to add.

### Virtual: Compile the Ast

Since we now have an Abstact syntax tree, it needs to be compiled to a virtual machine Instruction format.
For the parsed subset that's almost done.

It took me a while to come up with a decent but simple machine model. I had tried to map straight to hardware
but failed. The current Virtual directory represent a machine with basic oo features.

Instead of having more Layers to go from virtual to arm, i opted to have passes that go over the data structure
and modify it.

This allows optimisation after every pass as we have a data structure at every point in time.


## Status - Dynmic function lookup

It proved to be quite a big step to go from static function calling to oo method lookup. Also ruby is very 
introspective and that means much of the compiled code needs to be accessible in the runtime (not just present,
 accessible).
 
This has teken me the better part of three months, but is starting to come around.

So the current staus is that i can 

- parse a usable subset of ruby
- compile that to my vm model
- generate assembler for all higher level constructs in the vm model
- assemle and link the code and objects (strings/arrays/hashes) into an executable
- run the executable and debug :-(

## Future

#### Blocks

Implement ruby Blocks, and make new vm classes to deal with that. This is in fact a little open,
but i have a general notion that blocks are "just" methods with even more implicit arguments.

#### Exceptions

Implement Exceptions. Conceptionally this is not so difficult in an oo machine as it would be in c.

I have a post about it http://salama.github.io/2014/06/27/an-exceptional-though.html

which boild down to the fact that we can treat the address to return to in an exception quite
like a return address from a function. Ie just another implicit parameter
(as return is really an implicit parameter, a little like self for oo)

### C linking

Implement a way to call libc and other c libraries. I am not placing a large emphasis on this personally, 
but excpect somebody will come along and have library they want to use so much they can't stop themselves. 
Personally i think a fresh start is what we need much more. I once counted the call chain from a simple
printf to the actual kernel invocation in some libc once and it was getting to 10! I hope with dynamic (re)compiling
we can do better than that.

### Stary sky

Iterate:

1. more cpus (ie intel)
2. more systems (ie mac)
3. more syscalls, there are after all some hundreds
4. Ruby is full of nicities that are not done, also negative tests are non existant
5. A lot of modern cpu's functionality has to be mapped to ruby and implemented in assembler to be useful
6. Different sized machines, with different register types ?
7.  on 64bit, there would be 8 bits for types and thus allow for rational, complex, and whatnot
8. Housekeeping (the superset of gc) is abundant
9. Any amount of time could be spent on a decent digital tree (see judy). Or possibly Dr.Cliffs hash.
10. Also better string/arrays would be good.
11. The minor point of threads and hopefully lock free primitives to deal with that.
12. Inlining would be good

And generally optimize and work towards that perfect world (we never seem to be able to attain).



Contributing to salama
-----------------------
 
Probably best to talk to me, if it's not a typo or so.

I do have a todo, for the adventurous.

Fork and create a branch before sending pulls.

== Copyright

Copyright (c) 2014 Torsten Ruger. See LICENSE.txt for
further details.

