module vrepl.shell;

import dexpect;
import std.stdio;

class Shell {

    import std.datetime;
    bool isInit = false;
    Expect e;

    void init() {
        if (!isInit) {
            e = new Expect("/bin/bash");
            isInit = true;
        }
    }

    void read() {
        init();
        e.read(10.msecs);
    }

    string send(string line) {
        init();
        e.expect("$");
        e.sendLine(line);
        e.read();
        string resp = e.after[0..$];
        import std.string;
        auto pos = resp.indexOf('\n');
        auto pos1 = resp.lastIndexOf('\n');
        return resp[pos-1..pos1+1];
    }
}
