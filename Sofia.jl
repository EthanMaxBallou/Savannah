# Sofia

module Sofia

using DataFrames
using GLM

export run_all_EXP, run_all_DEP

# Module Path

# pwd() 
# cd("/Users/ethanballou/Documents/Coding/Julia/Modules")
# push!(LOAD_PATH,".")
# using Sofia



# Table of Contents ---------------------------------------------------------------------------------------------------------------------

# run_all_EXP
#  Takes a DataFrame and the name of an explanatory variable and runs every possible regression of one dependent variable
#  against two independent variables where the given variable is one of the explanatory variables. Outputs a DataFrame
#  object with the coefficent, and t value of the named variable along with the dependent variable and the formula

# run_all_DEP
#  Takes a DataFrame and the name of an dependent variable and runs every possible regression of one dependent variable
#  against two independent variables where the given variable is the dependent variable. Outputs a DataFrame
#  object with the formula, and the name, tvalue, coefficent of the independent variable with the largest t value






function run_all_EXP(df::DataFrame, target_variable::Union{String, Symbol})
    # Ensure the target_variable is a Symbol
    target_variable = Symbol(target_variable)

    # Convert all column names to Symbols
    all_vars = Symbol.(names(df))

    # Identify and print all variables with NaN values
    nan_vars = filter(var -> any(isnan.(df[:, var])), all_vars)
    if !isempty(nan_vars)
        println("Variables with NaN values that will drop regressions from the output:")
        println(nan_vars)
        println("\n \n")
    end 

    clean_vars = setdiff(all_vars, nan_vars)

    # Initialize an empty DataFrame to store results
    results_df = DataFrame(
        Coefficient = Float64[],
        DependentVariable = String[], 
        Formula = String[], 
        TValue = Float64[]
    )
    
    # Iterate over each variable as the dependent variable
    for dep_var in all_vars
        # Skip if the dependent variable is the target variable
        if dep_var == target_variable
            continue
        end

        # Exclude the dependent variable and target variable from the explanatory variables
        explanatory_vars = filter(x -> x != dep_var && x != target_variable, clean_vars)
        
        # Generate all combinations of one additional explanatory variable including the target variable
        for exp_var in explanatory_vars
            # Create terms for the formula
            formula = Term(dep_var) ~ Term(target_variable) + Term(exp_var)
            
            # Fit the model
            model = lm(formula, df)
            
            # Extract the t-value of the target variable
            t_value = abs(coef(model)[1] / stderror(model)[1])
            
            # Store the result in the DataFrame
            push!(results_df, (coef(model)[1], String(dep_var), string(formula), t_value))
        end
    end

    results_df = sort(results_df, :TValue, rev=true)
    results_df = filter(row -> isfinite(row[:TValue]), results_df)

    return results_df
end










function run_all_DEP(df::DataFrame, dependent_variable::Union{String, Symbol})
    # Ensure the dependent_variable is a Symbol
    dependent_variable = Symbol(dependent_variable)

    # Convert all column names to Symbols
    all_vars = Symbol.(names(df))

    # Identify and print all variables with NaN values
    nan_vars = filter(var -> any(isnan.(df[:, var])), all_vars)
    if !isempty(nan_vars)
        println("Variables with NaN values that will drop regressions from the output:")
        println(nan_vars)
        println("\n \n")
    end 

    clean_vars = setdiff(all_vars, nan_vars)

    # Exclude the dependent variable from the list of explanatory variables
    explanatory_vars = filter(x -> x != dependent_variable, clean_vars)

    # Initialize an empty DataFrame to store results
    results_df = DataFrame(
        Formula = String[], 
        Coefficient = Float64[],
        TValue = Float64[],
        EXPName = String[],
        AvgTVAL = Float64[]
    )

    # Generate all combinations of two explanatory variables
    for i in 1:(length(explanatory_vars) - 1)
        for j in (i + 1):length(explanatory_vars)
            # Create terms for the formula
            vars_to_include = [Term(explanatory_vars[i]), Term(explanatory_vars[j])]
            formula = Term(dependent_variable) ~ vars_to_include[1] + vars_to_include[2]
            
            # Fit the model
            model = lm(formula, df)
            
            # Extract the t-values of the two explanatory variables
            t_value1 = abs(coef(model)[1] / stderror(model)[1])  # i+1 because intercept is at index 1
            t_value2 = abs(coef(model)[2] / stderror(model)[2])  # j+1 because intercept is at index 1

            if abs(t_value1) > abs(t_value2)
                largest_t_value = t_value1
                largest_t_var = String(explanatory_vars[i])
                large_coef = coef(model)[1]
            else
                largest_t_value = t_value2
                largest_t_var = String(explanatory_vars[j])
                large_coef = coef(model)[2]
            end
            
            avgT = (t_value1 + t_value2)/2
            
            # Store the result in the DataFrame
            push!(results_df, (string(formula), large_coef, largest_t_value, largest_t_var, avgT))       
        end
    end

    results_df = sort(results_df, :TValue, rev=true)
    results_df = filter(row -> isfinite(row[:AvgTVAL]), results_df)

    return results_df
end



#Module End

end