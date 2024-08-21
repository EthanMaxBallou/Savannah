# Surya

module Surya

using DataFrames
using Statistics

export id_dataframe, id_dataframe!, employment_states!, calc_meansDF, RelativeCompareDF, calculate_stdevs_df

# Module Path

# pwd() 
# cd("/Users/ethanballou/Documents/Coding/Julia/Modules")
# push!(LOAD_PATH,".")
# using Surya



# Table of Contents ---------------------------------------------------------------------------------------------------------------------

# id_dataframe ( id_dataframe! )
#  Adds an ID column to a DataFrame and assigns ID numbers to every observation

# employment_states!
#  Takes longitudinal data in a DataFrame and assigns "emp" (employed) state to all non zero values, 
#  and "unemp" to all others

# calc_meansDF
#  Calculates the mean values of each numeric column/variable in a DataFrame object

# calculate_stdevs_df
#  Calculates standard deviations and return a DataFrame

# RelativeCompareDF
#  Takes two DataFrames and calculates the percentage difference between the mean values of each 
#  variable in both DataFrames along with standard deviations




# Adds an ID column to a DataFrame and assigns ID numbers to every observation

function id_dataframe(df::DataFrame, id_col_name::String = "ID")
    df[!, id_col_name] = 1:nrow(df)
    return df
end

function id_dataframe!(df::DataFrame, id_col_name::String = "ID")
    df[!, id_col_name] = 1:nrow(df)
    return df
end





# Takes longitudinal data in a DataFrame and assigns "emp" (employed) state to all non zero values, and "unemp" to all others

function employment_states!(df::DataFrame)
    for col in names(df)
        df[!, col] = ifelse.(df[!, col] .== 0, "unemp", "emp")
    end
    return df
end




# Calculates the mean values of each numeric column/variable in a DataFrame object

function calc_meansDF(df::DataFrame)
    col_names = String[]
    averages = Float64[]
    
    for col in names(df)
        # Check if the column contains numeric values
        if eltype(df[!, col]) <: Number
            # Calculate the mean of the column and store it
            push!(col_names, String(col))
            push!(averages, mean(df[!, col]))
        end
    end
    
    # Create a new DataFrame with the results
    result_df = DataFrame(Column = col_names, Average = averages)
    return result_df
end





# Calculates standard deviations and return a DataFrame

function calculate_stdevs_df(df::DataFrame)
    col_names = String[]
    stdevs = Float64[]
    
    for col in names(df)
        # Check if the column contains numeric values
        if eltype(df[!, col]) <: Number
            # Calculate the standard deviation of the column and store it
            push!(col_names, String(col))
            push!(stdevs, std(df[!, col]))
        end
    end
    
    # Create a new DataFrame with the results
    result_df = DataFrame(Column = col_names, Stdev = stdevs)
    return result_df
end




# Takes two DataFrames and calculates the percentage difference between the mean values of each variable in both DataFrames along with standard deviations

function RelativeCompareDF(df1::DataFrame, df2::DataFrame)
     # Calculate averages and standard deviations for both DataFrames
    avg_df1 = calc_meansDF(df1)
    avg_df2 = calc_meansDF(df2)
    stdev_df1 = calculate_stdevs_df(df1)
    stdev_df2 = calculate_stdevs_df(df2)
    
    
    # Create dictionaries to store the averages and standard deviations from df2 and stdev_df2
    avg_dict2 = Dict(row.Column => row.Average for row in eachrow(avg_df2))
    stdev_dict2 = Dict(row.Column => row.Stdev for row in eachrow(stdev_df2))
    
    # Initialize lists to store results
    col_names = String[]
    avg1_list = Float64[]
    avg2_list = Float64[]
    pct_diff_list = Float64[]
    avg_stdev_list = Float64[]
    
    # Iterate over the columns in df1's averages DataFrame
    for row in eachrow(avg_df1)
        col = row.Column
        avg1 = row.Average
        avg2 = get(avg_dict2, col, NaN)  # Get the average from df2, or NaN if not found

        # Find the corresponding standard deviations
        idx1 = findfirst(==(col), stdev_df1[!, :Column])
        idx2 = findfirst(==(col), stdev_df2[!, :Column])
        
        stdev1 = isnothing(idx1) ? NaN : stdev_df1[idx1, :Stdev]
        stdev2 = isnothing(idx2) ? NaN : stdev_dict2[col]
        
        # Calculate percentage difference, handling division by zero or missing values
        if isnan(avg2) || avg1 == 0.0
            pct_diff = NaN
        else
            pct_diff = 100 * abs((avg2 - avg1) / avg1)
        end
        
        # Calculate the average standard deviation between df1 and df2
        avg_stdev = mean(skipmissing([stdev1, stdev2]))
        
        # Store results
        push!(col_names, col)
        push!(avg1_list, avg1)
        push!(avg2_list, avg2)
        push!(pct_diff_list, pct_diff)
        push!(avg_stdev_list, avg_stdev)
    end
    
    # Create the final DataFrame
    result_df = DataFrame(
        Column = col_names,
        Average_df1 = avg1_list,
        Average_df2 = avg2_list,
        Percent_Diff = pct_diff_list,
        Average_Std = avg_stdev_list
    )
    
    # Sort the DataFrame by Percent_Difference from largest to smallest
    result_df = sort(result_df, :Percent_Diff, rev=true)
    
    return result_df
end




end