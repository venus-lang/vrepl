/**
 * Reference: 
 * https://github.com/antirez/linenoise
 * http://invisible-island.net/xterm/ctlseqs/ctlseqs.html
 * http://www.3waylabs.com/nw/WWW/products/wizcon/vt220.html
 **/
module vrepl;

import std.stdio: write, writeln;
import std.conv: to;
import dutil.containers;
import std.process;

alias StringSet = HashSet!string;

enum ES_CLEAR = "\x1b[H\x1b[2J";
enum ES_BEEP = "\x07";
enum Mode { SHELL, LINE, MLINE, EDIT }

class State {
    Mode mode = Mode.LINE;
}

class Config {
    string[Mode] prompt;
    StringSet quits;
    void delegate(string) onInput;

    this() {
        with(Mode) prompt = [
            SHELL: "$",
            LINE: ">",
            MLINE: ">>",
            EDIT: "*>"
        ];

        quits.add("quit", "bye", "exit");
    }
}

class Vrepl {
    Config config;
    State state;

    this() {
        config = new Config();
        state = new State();
    }

    void prompt() {
        write(config.prompt[state.mode] ~ " ");
    }

    bool checkMode(string line) {
        import std.string: chomp;
        if (line == "mode shell") {
            state.mode = Mode.SHELL;
            writeln("Change Mode: ", "shell");
            return false;
        } else if (line == "mode line") {
            state.mode = Mode.LINE;
            writeln("Change Mode: ", "line");
            return false;
        } else if (line.chomp == "") {
            writeln("empty");
            return false;
        } else {
            return true;
        }
    }

    void quit() { }

    bool isQuit(string line) {
        return config.quits.contains(line);
    }

    ProcessPipes pipes;
    void loop() {
        import std.string: chomp;
        import std.stdio: stdin, readln;

        import core.stdc.signal;
        signal(21, SIG_IGN);
        signal(22, SIG_IGN);
        signal(23, SIG_IGN);
        string line;
        prompt();
        while ((line = stdin.readln) !is null) {

            line = line.chomp;
            if (isQuit(line)) return;
            if (!checkMode(line)) {
                prompt();
                continue;
            }
            with (Mode) switch (state.mode) {
                case LINE:
                    if (line == "clear") {
                        writeln(ES_CLEAR);
                    } else if (line == "beep") {
                        writeln(ES_BEEP);
                    } else {
                        if (config.onInput != null) {
                            config.onInput(line);
                        } else {
                            writeln("your wrote:", line);
                        }
                    }
                    prompt();
                    quit();
                    break;
                case SHELL:
                    writeln("shellll");
                    writeln("shell");
                    {
                        import std.process;
                        /*
                        pipes = pipeProcess(["/bin/bash", "-i", "-l"], Redirect.all);
                        scope(exit) tryWait(pipes.pid);
                        pipes.stdin.writeln(line);
                        pipes.stdin.writeln("\r\n");
                        //pipes.stdin.close();
                        import core.stdc.stdio;
                        foreach (buf; pipes.stdout.byLine) {
                            writeln(buf);
                        }
                        */

                        // wait(spawnProcess(["/bin/bash", "-i", "-c", line]));
                           auto r = executeShell("/bin/bash -i -c '" ~ line ~ "'");
                           if (r.status !=0) {
                           writeln("error executing:", line);
                           } else {
                           writeln(r.output);
                           }

                    }
                    prompt();
                    break;
                default:
                    break;
            }
            quit();

        }
    }

}
