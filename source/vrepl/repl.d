/**
 * Reference: 
 * https://github.com/antirez/linenoise
 * http://invisible-island.net/xterm/ctlseqs/ctlseqs.html
 * http://www.3waylabs.com/nw/WWW/products/wizcon/vt220.html
 **/
module vrepl.repl;

import std.stdio: write, writeln;
import std.conv: to;
import dutil.containers;
import std.process;
import vrepl.shell;

alias StringSet = HashSet!string;

enum SIGTTIN = 21;
enum SIGTTOU = 22;
enum ES_CLEAR = "\x1b[H\x1b[2J";
enum ES_BEEP = "\x07";
enum Mode { SHELL, LINE, MLINE, EDIT }

class State {
    Mode mode = Mode.LINE;
}

extern(C) void sig_hand(int signal) nothrow @nogc @system {
    import core.stdc.stdio: printf;
    printf("signal %d catched!\n", signal);
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
    Shell shell;

    this() {
        config = new Config();
        state = new State();
        shell = new Shell();
    }

    void setMode(Mode m) {
        this.state.mode = m;
    }

    void prompt() {
        if (state.mode == Mode.SHELL) {
            write(config.prompt[Mode.SHELL] ~ " ");
        } else {
            write(config.prompt[state.mode] ~ " ");
        }
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

        /*
        import core.stdc.signal;
        signal(SIGTTIN, &sig_hand);
        signal(SIGTTOU, &sig_hand);
        */
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
                    {
                        write(shell.send(line));
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
