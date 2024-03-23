// в модуле сначало идет заполнение памяти fill_data     ()
//                            затем чтение requset_read  () 3 раза (1 для каждого случая)
//                           затем  запись requset_write () 3 раза (1 для каждого случая)

module bram_dp_true_2clk_tb();
  localparam int RAM_WIDTH     = 16;
  localparam int RAM_ADDR_BITS = 3;
  localparam int RAM_DEPTH     = 2**RAM_ADDR_BITS;

  logic                           clk_a_i;
  logic                           clk_b_i;
  logic [ RAM_ADDR_BITS - 1 : 0 ] addr_a_i;
  logic [ RAM_ADDR_BITS - 1 : 0 ] addr_b_i;
  logic [ RAM_WIDTH     - 1 : 0 ] data_a_i;
  logic [ RAM_WIDTH     - 1 : 0 ] data_b_i;
  logic                           we_a_i;
  logic                           we_b_i;
  logic                           en_a_i;
  logic                           en_b_i;
  logic [ RAM_WIDTH     - 1 : 0 ] data_a_o;
  logic [ RAM_WIDTH     - 1 : 0 ] data_b_o;

  bram_dp_true_2clk # (
    .RAM_WIDTH     ( RAM_WIDTH     ),
    .RAM_ADDR_BITS ( RAM_ADDR_BITS )
  )
  bram_dp_true_2clk_inst (
    .clk_a_i  ( clk_a_i  ),
    .clk_b_i  ( clk_b_i  ),
    .addr_a_i ( addr_a_i ),
    .addr_b_i ( addr_b_i ),
    .data_a_i ( data_a_i ),
    .data_b_i ( data_b_i ),
    .we_a_i   ( we_a_i   ),
    .we_b_i   ( we_b_i   ),
    .en_a_i   ( en_a_i   ),
    .en_b_i   ( en_b_i   ),
    .data_a_o ( data_a_o ),
    .data_b_o ( data_b_o )
  );
//------------------------------------------------- clk
initial begin
  clk_a_i = 1'b0;
  forever begin
    clk_a_i = ~clk_a_i; #5;
  end
end

initial begin
  clk_b_i = 1'b1; #2.5;
  forever begin
    clk_b_i = ~clk_b_i; #5;
  end
end
//------------------------------------------------- WRITE MODULE
int p;
event end_of_fill;

  initial begin
  #10;
  p    = 0;
  we_a_i = '0;

  repeat(RAM_DEPTH/2)begin      // заполнение памяти сразу 2 ячеек
    fill_data(); #5;
    p = p + 2;
  end

  ->end_of_fill;
  wait(end_of_read.triggered)// ждем окончания чтения
  #10;
  requset_write_a();           // запись в память
  #30;
  requset_write_b();
  #30;
  requset_write_both();
  #30
  $finish;
end

task fill_data();
  @(posedge clk_a_i)
    addr_a_i = p;
    we_a_i   = '1;
    en_a_i   = '1;
    data_a_i = $urandom_range(0, 2**RAM_WIDTH - 1);
  @(posedge clk_b_i)
    addr_b_i = p + 1;
    we_b_i   = '1;
    en_b_i   = '1;
    data_b_i = $urandom_range(0, 2**RAM_WIDTH - 1);
  @(posedge clk_a_i)
    we_a_i = '0;
    en_a_i = '0;
    @(posedge clk_b_i);
    en_b_i = '0;
    we_b_i = '0;
endtask

task requset_write_a();
  @(posedge clk_a_i)
    addr_a_i = $urandom_range(0, RAM_DEPTH - 1);
    we_a_i   = '1;
    en_a_i   = '1;
    data_a_i = $urandom_range(0, 2**RAM_WIDTH - 1);
  #5; @(posedge clk_a_i)
    we_a_i = '0;
    en_a_i = '0;
endtask

task requset_write_b();
  @(posedge clk_b_i)
    addr_b_i = $urandom_range(0, RAM_DEPTH - 1);
    we_b_i   = '1;
    en_b_i   = '1;
    data_b_i = $urandom_range(0, 2**RAM_WIDTH - 1);
  #5; @(posedge clk_b_i)
    en_b_i = '0;
    we_b_i = '0;
endtask
//------------------------------------------------- READ MODULE
event end_of_read;
initial begin
  wait(end_of_fill.triggered) // ждем окончания заполнения памяти
  #10;                        // чтение памяти
  requset_read_a();
  #30;
  requset_read_b();
  #30;
  ->end_of_read;
end

task requset_read_a();
  @(posedge clk_a_i)
    en_a_i   = 1'b1;
    addr_a_i = $urandom_range(0, RAM_DEPTH - 1);
  #5; @(posedge clk_a_i);
    en_a_i   = 1'b0;
endtask

task requset_read_b();
  @(posedge clk_b_i)
    en_b_i   = 1'b1;
    addr_b_i = $urandom_range(0, RAM_DEPTH - 1);
  #5; @(posedge clk_b_i);
    en_b_i   = 1'b0;
endtask

endmodule
