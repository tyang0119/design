@echo off
set xv_path=C:\\Apps\\Xilinx\\Vivado\\2017.2\\bin
call %xv_path%/xsim Axi4liteRegs_tb_behav -key {Behavioral:sim_1:Functional:Axi4liteRegs_tb} -tclbatch Axi4liteRegs_tb.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
