vlib work
vlog  +define+SIM -f srcfiles.list +cover -covercells
vsim -voptargs=+acc work.top -cover 
add wave /top/fifo_if/*
coverage save top.ucdb -onexit
run -all