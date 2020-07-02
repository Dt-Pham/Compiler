class Main inherits A2I {

    io : IO <- new IO;
    main(): Object {
        let n: Int <- a2i(io.in_string()),
            res: Int <- 1,
            i: Int <- 0
        in
        {
            while i < n loop
            {
                i <- i + 1;
                res <- res * i;
            }
            pool;
            io.out_string(i2a(res).concat("\n"));
        }
    };
};