class List inherits A2I {
    value: Object;
    next: List;

    init(v: Object, n: List): List {
        {
            value <- v;
            next <- n;
            self;
        }
    };

    flatten(): String {
        let str: String <- 
            case value of
                i: Int => i2a(i);
                s: String => s;
                o: Object => {abort(); "";};
            esac
        in
            if (isvoid next) then
                str
            else
                str.concat(next.flatten())
            fi
    };
};

class Main inherits IO {
    main(): Object {
        let hello: String <- "Hello ",
            world: String <- "world!",
            i: Int <- 2020,
            newline: String <- "\n",
            nil: List,
            list: List <-
                (new List).init(
                    hello, (new List).init(
                        world, (new List).init(
                            i, (new List).init(
                                newline, nil
                            )
                        )
                    )
                )
        in
            out_string(list.flatten())
    };
};