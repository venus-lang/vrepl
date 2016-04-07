import std.stdio;
import std.string: chomp;
import std.conv: to;

import vrepl;

void main()
{
		auto repl = new Vrepl;
		repl.setPrompt("$");
		repl.loop();
}
