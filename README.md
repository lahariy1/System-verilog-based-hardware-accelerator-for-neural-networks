# System-verilog-based-hardware-accelerator-for-neural-networks
Constructed a system for efficient evaluation of neural network layers with predefined parameters.Enhanced the design for efficient saturating matrix-vector multiplication using pipelining and parallelism, increasing
operating frequency from 689MHz to 1.25GHz and halving the delay, crucial for neural network computations.Extended the above implementation to create a Hardware Generation Tool (HGT) in C++, capable of generating a
three-layer Fully Connected Neural Network (FCNN) based on input network dimensions and multiplier budget.Formulated an optimization algorithm to tailor parallelism levels for each of the three layers within a fixed multiplier
budget, boosting overall system throughput by 40% and a peak operating frequency of 800MHz.
