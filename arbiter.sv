module arbiter #(
    parameter N = 4
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [N-1:0] req,
    output reg  [N-1:0] grant
);
    reg [$clog2(N)-1:0] priority_ptr;
    integer i;

    reg [N-1:0]         next_grant;
    reg [$clog2(N)-1:0] next_ptr;

    always @(*) begin
        next_grant = 0;
        next_ptr   = priority_ptr;
        for (i = 0; i < N; i = i + 1) begin
            if (next_grant == 0 && req[(priority_ptr + i) % N]) begin
                next_grant[(priority_ptr + i) % N] = 1;
                next_ptr = (priority_ptr + i + 1) % N;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            grant        <= 0;
            priority_ptr <= 0;
        end else begin
            grant        <= next_grant;
            priority_ptr <= next_ptr;
        end
    end

`ifdef FORMAL
    reg [1:0] f_cycle;
    initial f_cycle = 0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            f_cycle <= 0;
        else if (f_cycle < 3)
            f_cycle <= f_cycle + 1;
    end

    initial assume(!rst_n);

    always @(posedge clk) begin
        // 1. No grant during reset
        if (!rst_n)
            assert(grant == 0);

        if (rst_n && f_cycle >= 2) begin
            // 2. At most one grant at a time (onehot0)
            assert(grant == 0 || (grant & (grant - 1)) == 0);

            // 3. Grant only when the PAST request was active
            //    (grant is registered — it reflects req from last cycle)
            assert((grant & $past(req)) == grant);

            // 4. No grant when there were no requests last cycle
            if ($past(req) == 0)
                assert(grant == 0);
        end
    end

    always @(posedge clk) begin
        if (rst_n && f_cycle >= 2) begin
            cover(grant[0]);
            cover(grant[1]);
            cover(grant[2]);
            cover(grant[3]);
            cover(req == 4'b1111);
        end
    end
`endif

endmodule
