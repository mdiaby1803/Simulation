* Import Dataset (Make sure to put your own path)
import excel "C:\Users\meman\Downloads\Task 1 simulation data.xlsx", sheet("full combined data set") firstrow 

* Display the first few rows to inspect the data
list in 1/10

* Scatter plot of Initial_amt vs. PIF_amt
scatter PIF_amt initial_amt 

* Fit a linear regression model
regress PIF_amt initial_amt 

* Store the coefficients for simulation
matrix b = e(b)
local intercept = b[1,1]
local slope = b[1,2]

* Display the coefficients
display "Intercept: " `intercept'
display "Slope: " `slope'

* Define a program to simulate the chain of giving
program define simulate_chain, rclass
    args initial_amt rounds intercept slope
    tempname chain
    matrix `chain' = J(`rounds', 1, .)
    matrix `chain'[1,1] = `initial_amt'
    forvalues i = 2/`rounds' {
        local prev_amt = matrix(`chain'[`i'-1, 1])
        local next_amt = `intercept' + `slope' * `prev_amt'
        if `next_amt' < 0 {
            local next_amt = 0
        }
        if `next_amt' > 20 {
            local next_amt = 20
        }
        matrix `chain'[`i', 1] = `next_amt'
    }
    return matrix chain = `chain'
end

* Create a dataset with 6 observations for storing results
gen round = _n if _n <= 6

* Predefine variables for each initial condition
foreach initial in 0 5 10 15 20 {
    local colname = "initial_`initial'"
    gen `colname' = . if _n <= 6
}

* Simulate chains for different initial conditions and store results
foreach initial in 0 5 10 15 20 {
    simulate_chain `initial' 6 `intercept' `slope'
    matrix chain = r(chain)
    local colname = "initial_`initial'"
    forvalues i = 1/6 {
        replace `colname' = chain[`i', 1] in `i'
    }
}

* Line plot of the simulation results
line initial_0 initial_5 initial_10 initial_15 initial_20 round

* Save the graph in a pdf format (Make sure to put your own path)
graph export "C:\Users\meman\Downloads\Task1.pdf", as(pdf) name("Graph")
