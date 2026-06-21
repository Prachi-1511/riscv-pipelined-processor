module hazard_unit (
    input wire idex_mem_read,       // is the instr in the EX stage a load?
    input wire [4:0] idex_rd,       // what register is load writing to?
    input wire [4:0] ifid_rs1,      // what does ID currently need to read from rs1?  
    input wire [4:0] ifid_rs2,
    output wire      stall,
    output wire      pc_write_disable,
    output wire      ifid_write_disable
);

    // Load-use hazard
    assign stall = idex_mem_read && ((idex_rd == ifid_rs1) || (idex_rd == ifid_rs2)) && (idex_rd != 5'b0);
    
    assign pc_write_disable = stall;
    assign ifid_write_disable = stall;

endmodule