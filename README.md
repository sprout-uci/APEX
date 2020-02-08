# VAPE:

Modern society is increasingly surrounded by, and is growingaccustomed to, a wide range of Cyber-Physical Systems (CPS),Internet-of-Things (IoT), andsmartdevices. They often per-form safety-critical functions, e.g., personal medical devices,automotive CPS as well as industrial and residential automa-tion (e.g., sensor-alarm combinations). On the lower end of thescale, these devices are small, cheap and specialized sensorsand/or actuators. They tend to be equipped with small anemicCPU, have small amounts of memory and run simple software.If such devices are left unprotected, consequences of forgedsensor readings or ignored actuation commands can be catas-trophic, particularly, in safety-critical settings. This prompts the following three questions:(1) How to trust data produced,or verify that commads were performed, by a simple remoteembedded device?,(2) How to bind these actions/results tothe execution of expected software?and,(3) Can (1) and (2)be attained even if all software on a device could be modifiedand/or compromised?

In  this  work  we  answer  these  questions  by  designing, showing security of, and formally verifying,VAPE:VerifiedArchitecture forProofs ofExecution. To the best of our knowl-edge, this is the first of its kind result for low-end embeddedsystems. Our work has a range of applications, especially, toauthenticated sensing and trustworthy actuation, which are in-creasingly relevant in the context of safety-critical systems.VAPEarchitecture is publicly available and our evaluation in-dicates that it incurs low overhead, affordable even for verylow-end embedded devices, e.g., those based on TI MSP430 or AVR ATmega processors.

### VAPE Directory Structure

├── msp_bin
├── openmsp430
│   ├── contraints_fpga
│   ├── fpga
│   ├── msp_core
│   ├── msp_memory
│   ├── msp_periph
│   └── simulation
├── scripts
│   ├── build
│   ├── build-verif
│   └── verif-tools
├── simple_app
│   └── simulation
├── test
│   └── simulation
├── utils
├── verification_specs
│   └── soundness_and_security_proofs
├── verifier
├── violation_forge_ER
│   └── simulation
├── violation_forge_META
│   └── simulation
├── violation_forge_OR
│   └── simulation
└── vrased
    ├── hw-mod
    │   └── hw-mod-auth
    └── sw-att
        └── hacl-c


## Building VRASED Software
To generate the Microcontroller program memory configuration containing VRASED trusted software (SW-Att) and sample application (in application/main.c) code run:

        cd scripts
        make mem

To clean the built files run:

        make clean

As a result of the build, two files pmem.mem and smem.mem should be created inside msp_bin directory:

- pmem.mem program memory contents corresponding the application binaries

- smem.mem contains SW-Att binaries.

        Note: Latest Build tested using msp430-gcc (GCC) 4.6.3 2012-03-01

## Running VRASED Prototype on FPGA

This is an example of how to synthesize and prototype VRASED using Basys3 FPGA and XILINX Vivado v2017.4 (64-bit) IDE for Linux

- Vivado IDE is available to download at: https://www.xilinx.com/support/download.html

- Basys3 Reference/Documentation is available at: https://reference.digilentinc.com/basys3/refmanual

#### Creating a Vivado Project for VRASED

1 - Clone this repository;

2 - Follow the steps in [Building VRASED Software](#building-vrased-software) to generate .mem files

2- Start Vivado. On the upper left select: File -> New Project

3- Follow the wizard, select a project name and location. In project type, select RTL Project and click Next.

4- In the "Add Sources" window, select Add Files and add all *.v and *.mem files contained in the following directories of this reposiroty:

        openmsp430/fpga
        openmsp430/msp_core
        openmsp430/msp_memory
        openmsp430/msp_periph
        /vrased/hw-mod
        /msp_bin

and select Next.

5- In the "Add Constraints" window, select add files and add the file

        openmsp430/contraints_fpga/Basys-3-Master.xdc

and select Next.

        Note: this file needs to be modified accordingly if you are running VRASED in a different FPGA.

6- In the "Default Part" window select "Boards", search for Basys3, select it, and click Next.

        Note: if you don't see Basys3 as an option you may need to download Basys3 to Vivado.

7- Select "Finish". This will conclude the creation of a Vivado Project for VRASED.

Now we need to configure the project for systhesis.

8- In the PROJECT MANAGER "Sources" window, search for openMSP430_fpga (openMSP430_fpga.v) file, right click it and select "Set as Top".
This will make openMSP430_fpga.v the top module in the project hierarchy. Now its name should appear in bold letters.

9- In the same "Sources" window, search for openMSP430_defines.v file, right click it and select Set File Type and, from the dropdown menu select "Verilog Header".

Now we are ready to synthesize openmsp430 with VRASED's hardware the following steps might take several minutes.

10- On the left menu of the PROJECT MANAGER click "Run Synthesis", select execution parameters (e.g, number of CPUs used for synthesis) according to your PC's capabilities.

11- If synthesis succeeds, you will be prompted with the next step. Select "Run Implementation" and wait a few more minutes (typically ~3-10 minutes).

12- If implementation succeeds select "Generate Bitstream" in the following window. This will generate the configuration binary to step up the FPGA according to VRASED hardware and software.

13- After the bitstream is generated, select "Open Hardware Manager", connect the FPGA to you computers USB port and click "Auto-Connect".
Your FPGA should be now displayed on the hardware manager menu.

        Note: if you don't see your FPGA after auto-connect you might need to download Basys3 drivers to your computer.

14- Right-click your FPGA and select "Program Device" to program the FPGA.

15- If everything succeeds your FPGA should be displaying a pattern similar to the on in the video in /demo/vrased.mp4.

When all LD0 to LD8 are on at the same time, VRASED is computing attestation of the openmsp430's program memory.

## Running VRASED on Vivado Simulation Tools

1) In Vivado, click "Add Sources" (Alt-A), then select "Add or create simulation sources", click "Add Files", and select everything in openmsp430/simulation.
2) Now, navigate "Sources" window in Vivado. In "Simulation Sources" tab, set "tb_openMSP430_fpga.v" as top module
3) Assuming we want to run simulation  of PoX from the code in folder XX, open a linux terminal, go inside the scripts folder and run "make XX", i.e., "make simple_app" for "simple_app" testcase.
4) Go back to VIVADO window and in the "Flow Navigator" tab (in the left), click "Run Simulation", then "Run Behavioral Simulation".
5) Add how much time you want to run (See each testcase below) and do "Shift+F2" to run.
6) In the green wave window you will see values for several signals. The imporant ones are "p3_dout[7:0]", "exec", and "pc[15:0]". pc cointains the program counter value. exec corresponds to the value of VAPE's exec flag, described in the paper. p3_dout[7:0] will store the token generated as a proof of execution.

For all testcases, in Vivado simulation, the final value of pc[0:15] should correspond to instructions in "success" function (i.e., the program should halt in such function).
To determine instruction range of "success" function (values of ER_min and ER_max, per VAPE's paper), one can look into scripts/tmp-build/XX/vrased.lst and search for "success"

Description of each testcase:

- simple_app: corresponds to a toy proof of execution, i.e., (1) execute "dummy_function", (2) compute proof of execution token via attestation, (3) output the token (in this case, write it to P3OUT (p3_dout[7:0] in vivado simulation window).
At the end of simple_app's simulation, P3OUT (over time) should store the correct authenticated token value: "B29641FABECD66607521F0CAEA21590C6AEB0F79DE4D0A435251B94B6D6F636B". 
See utils/get_token_simple_app.py for how this token is generated.
In this testcase, you need to run the simulation for 800ms (in simulation time, not real-time) to generate the authenticated token value on P3OUT.

NOTE: running 800ms of simulation may take several minutes. Zooming out the the waves windows can help in speeding up the process.

- violation_forge_ER: corresponds to a testcase where code in region ER is overwritten after it executed. less than 1ms to complete simulation.

- violation_forge_OR: corresponds to a testcase where result in OR region is overwritten after ER executed. less than 1ms to complete simulation.

- violation_forge_META: correspond to a testcase where METADATA value is overwritten after ER executed. less than 1ms to complete simulation.

NOTE: In the violation cases authetication token result (in p3_dout[7:0]) should *NOT* correspond to "B29641FABECD66607521F0CAEA21590C6AEB0F79DE4D0A435251B94B6D6F636B". Since there was a (malicious) violation, the prover should not be able to produce the correct authenticated token (proof of execution).

## Running VAPE via Command Line Simulation

        cd scripts
        make run

This command line simulation is the fastest option, but it will only print the contents of the microcontroller registers at each cycle. It is only useful for debugging purposes.
For more resourceful simulation follow [Running VRASED on Vivado Simulation Tools](#building-vrased-software).

## Running VAPE Verification

First we need to install the verification tools:

        cd scripts
        make install

To check HW-Mod against VRASED and VAPE LTL subproperties using NuSMV run:

        make verify

To run VAPE and VRASED end-to-end implementation proofs check the readme file in:

        verification_specs/soundness_and_security_proofs

