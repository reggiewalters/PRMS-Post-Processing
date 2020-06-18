# load fitting parameters for polynomial adjustment function
#     each column represents parameters p1-p4 for each of 3 temporal bins
#     column one:   Nov-Feb
#     column two:   Mar-Jun
#     column three: Jul-Oct

P_HH <- matrix(c(-0.0031, -0.0122, 2.4722, 3.7852, 0.0023, -0.0025, -0.7188, 1.0779, -0.0127, 0.0094, 8.9121, -9.6569), ncol = 3)
P_CH <- matrix(c(-0.0006, -0.0099, 0.5472, 2.9746, -0.0007, 0.0070, 0.5265, -5.9535, -0.0026, 0.0263, 2.4669, -25.6689), ncol = 3)
P_DP <- matrix(c(-0.0022, 0.0204, 1.3324, -16.3090, -0.0006, 0.0217, 0.6075, -18.6052, 0.0005, 0.0158, -0.4515, -12.5753), ncol = 3)
P_LAG <- matrix(c(-0.0010, 0.0008, 0.8516, -7.0699, -0.0004, 0.0088, 0.4349, -9.0777, -0.0031, 0.0332, 2.7864, -31.4835), ncol = 3)

# concatenate the fitting parameters into a single data cube of size [4 x 3 x 4]
P_ALL = array(c(P_HH, P_CH, P_DP, P_LAG), c(4, 3, 4))

# monthly bins for paramter fits
PMonths <- matrix(c(11, 12, 1:10), ncol = 3)

# specify CPI Beta Values for each model (HH, CH, DP, LaG)
Beta_Array <- c(0.91, 0.99, 0.99, 0.99) 

# Specify coefficients for Box-Cox model data transformation
coeff <- c(10.3219, 6.7181, 9.8626, 26.0570)
Lambda <- 0.20
nM <- 4 # Number of Models
