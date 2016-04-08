import std.stdio;
import std.string: chomp;
import std.conv: to;

import vrepl;

void main()
{
    auto repl = new Vrepl;
    //repl.state.mode = Mode.SHELL;
    repl.config.prompt[Mode.LINE] = "~";
    repl.config.onInput = x => writeln("zecho: ", x);
    repl.loop();
}
