#!/bin/bash
# run_all.sh -- compiles and runs every testbench in the project, Day 1-29
# Usage: bash sim/run_all.sh   (run from repo root)

set -e
mkdir -p sim/logs

RTL="rtl"
TB="tb"

run_test() {
    NAME=$1
    shift
    echo "----- Running: $NAME -----"
    iverilog -o sim/${NAME}_sim "$@" > sim/logs/${NAME}_compile.log 2>&1
    vvp sim/${NAME}_sim | tee sim/logs/${NAME}_run.log
    echo ""
}

run_test alu           $RTL/alu.v $TB/alu_tb.v
run_test regfile        $RTL/regfile.v $TB/regfile_tb.v
run_test fetch          $RTL/pc.v $RTL/imem.v $TB/fetch_tb.v
run_test single_cycle    $RTL/riscv_defs.vh $RTL/pc.v $RTL/imem.v $RTL/regfile.v $RTL/alu.v $RTL/control.v $RTL/imm_gen.v $RTL/dmem.v $RTL/top_single_cycle.v $TB/top_single_cycle_tb.v
run_test pipeline_regs   $RTL/pipeline_regs.v $TB/pipeline_regs_tb.v
run_test hazard         $RTL/hazard_unit.v $TB/hazard_tb.v
run_test forwarding      $RTL/forwarding_unit.v $TB/forwarding_tb.v
run_test pipeline_final  $RTL/riscv_defs.vh $RTL/pc.v $RTL/imem.v $RTL/regfile.v $RTL/alu.v $RTL/control.v $RTL/imm_gen.v $RTL/dmem.v $RTL/pipeline_regs.v $RTL/if_stage.v $RTL/id_stage.v $RTL/ex_stage.v $RTL/mem_stage.v $RTL/wb_stage.v $RTL/hazard_unit.v $RTL/forwarding_unit.v $RTL/top_pipeline.v $TB/pipeline_final_tb.v
run_test branch_perf     $RTL/branch_predictor.v $TB/branch_perf_tb.v
run_test bht            $RTL/branch_predictor.v $TB/bht_tb.v
run_test icache         $RTL/icache.v $TB/icache_tb.v
run_test dcache         $RTL/dcache.v $TB/dcache_tb.v
run_test cache_ctrl      $RTL/cache_ctrl.v $TB/cache_ctrl_tb.v
run_test cache_integrate $RTL/top_pipeline.v $RTL/icache.v $RTL/dcache.v $RTL/cache_ctrl.v $RTL/pipeline_regs.v $RTL/if_stage.v $RTL/id_stage.v $RTL/ex_stage.v $RTL/mem_stage.v $RTL/wb_stage.v $RTL/hazard_unit.v $RTL/forwarding_unit.v $RTL/branch_predictor.v $TB/top_pipeline_cache_tb.v
run_test axi_master      $RTL/axi_lite_master.v $TB/axi_lite_master_tb.v
run_test axi_loopback    $RTL/axi_lite_master.v $RTL/axi_lite_slave.v $TB/axi_loopback_tb.v
run_test valid_prop      $RTL/top_pipeline.v $RTL/icache.v $RTL/dcache.v $RTL/cache_ctrl.v $RTL/pipeline_regs.v $RTL/if_stage.v $RTL/id_stage.v $RTL/ex_stage.v $RTL/mem_stage.v $RTL/wb_stage.v $RTL/hazard_unit.v $RTL/forwarding_unit.v $RTL/branch_predictor.v $RTL/perf_counters.v $TB/valid_propagation_tb.v
run_test soc_top        $RTL/soc_top.v $RTL/top_pipeline.v $RTL/icache.v $RTL/dcache.v $RTL/cache_ctrl.v $RTL/pipeline_regs.v $RTL/if_stage.v $RTL/id_stage.v $RTL/ex_stage.v $RTL/mem_stage.v $RTL/wb_stage.v $RTL/hazard_unit.v $RTL/forwarding_unit.v $RTL/branch_predictor.v $RTL/perf_counters.v $RTL/axi_lite_master.v $RTL/axi_lite_slave.v $TB/soc_top_tb.v
run_test soc_assertions  $RTL/soc_top.v $RTL/top_pipeline.v $RTL/icache.v $RTL/dcache.v $RTL/cache_ctrl.v $RTL/pipeline_regs.v $RTL/if_stage.v $RTL/id_stage.v $RTL/ex_stage.v $RTL/mem_stage.v $RTL/wb_stage.v $RTL/hazard_unit.v $RTL/forwarding_unit.v $RTL/branch_predictor.v $RTL/perf_counters.v $RTL/axi_lite_master.v $RTL/axi_lite_slave.v $TB/pipeline_assertions.v $TB/soc_top_tb.v
run_test soc_coverage    $RTL/soc_top.v $RTL/top_pipeline.v $RTL/icache.v $RTL/dcache.v $RTL/cache_ctrl.v $RTL/pipeline_regs.v $RTL/if_stage.v $RTL/id_stage.v $RTL/ex_stage.v $RTL/mem_stage.v $RTL/wb_stage.v $RTL/hazard_unit.v $RTL/forwarding_unit.v $RTL/branch_predictor.v $RTL/perf_counters.v $RTL/axi_lite_master.v $RTL/axi_lite_slave.v $TB/pipeline_assertions.v $TB/coverage_model.v $TB/soc_top_tb.v
run_test scan_ff         $RTL/scan_ff.v $TB/scan_ff_tb.v

echo "===== ALL TESTBENCHES COMPLETE — see sim/logs/ for individual outputs ====="