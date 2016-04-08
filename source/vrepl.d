module vrepl;

import std.stdio: write, writeln;
import std.conv: to;
import dutil.containers;
import std.process;

alias StringSet = HashSet!string;

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

        string line;
        with (Mode) switch (state.mode) {
            case LINE:
                prompt();
                while ((line = stdin.readln) !is null) {
                    line = line.chomp;
                    if (isQuit(line)) return;
                    if (checkMode(line)) {
                        if (config.onInput != null) {
                            config.onInput(line);
                        } else {
                            writeln("your wrote:", line);
                        }
                    }
                    prompt();
                }
                quit();
                break;
            case SHELL:
                prompt();
                while ((line = stdin.readln) !is null) {
                    line = line.chomp;
                    if (isQuit(line)) return;
                    if (checkMode(line)) {
                        {
                            import std.process;
                            /*
                            pipes = pipeProcess(["/bin/bash", "-i", "-l"], Redirect.all);
                            scope(exit) tryWait(pipes.pid);
                            pipes.stdin.writeln(line);
//                            pipes.stdin.writeln("\r\n");
                            pipes.stdin.close();
                            import core.stdc.stdio;
                            foreach (buf; pipes.stdout.byLine) {
                                writeln(buf);
                            }
                            */

                            wait(spawnProcess(["/bin/bash", "-i", "-c", line]));
                            //auto r = executeShell("/bin/bash -c " ~ line);
                        }
                    }
                    prompt();
                }
                quit();
                break;
            default:
                break;
        }

    }
}

