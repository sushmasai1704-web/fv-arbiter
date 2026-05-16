module arbiter_sva (
  input  clk, rst_n,
  input  [3:0] req,
  output reg [3:0] grant
);

  // simple round-robin RTL
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) grant <= 4'b0;
    else begin
      if      (req[0]) grant <= 4'b0001;
      else if (req[1]) grant <= 4'b0010;
      else if (req[2]) grant <= 4'b0100;
      else if (req[3]) grant <= 4'b1000;
      else             grant <= 4'b0000;
    end
  end

  // SVA properties
  property no_grant_reset;
    @(posedge clk) !rst_n |-> (grant == 4'b0);
  endproperty

  property one_hot_grant;
    @(posedge clk) disable iff (!rst_n)
    $onehot0(grant);
  endproperty

  property grant_needs_request;
    @(posedge clk) disable iff (!rst_n)
    |grant |-> $past(|req, 1);
  endproperty

  assert_reset:   assert property (no_grant_reset);
  assert_onehot:  assert property (one_hot_grant);
  assert_req:     assert property (grant_needs_request);

endmodule
