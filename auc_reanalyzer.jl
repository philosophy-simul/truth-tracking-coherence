using HypothesisTests
using PlotlyJS
using Distributed
addprocs()
@everywhere begin
    using Distributions
    using DataFrames
    using StatsBase
end

function aucPlot_from_csv(name::String,file::String,titula2::String,csvs,range1=0,range2=100,dynamic=0)
    if titula2==""
        out_ar=csv_to_out_ar(file)
        out_auc=mean(out_ar, dims=3)
        if dynamic==1
            range1=parse(Int64,(file[findfirst("auc-",file)[4]+2]))*2
            while range1%5>0
                range1+=1
            end
        end
        if occursin("a0_0.",file)
           titula="True enough pieces of info: "*file[findfirst("autogenerated_",file)[end]+1]*" (of "*file[findfirst("auc-",file)[4]+2]*"), a0 = ."*file[findfirst("a0_0.",file)[5]+1]
        else
           titula="True enough pieces of info: "*file[findfirst("autogenerated_",file)[end]+1]*" (of "*file[findfirst("auc-",file)[4]+2]*"), a0 not fixed"
        end
    else
        titula=titula2
        out_auc=average_out_ar_from_list(csvs)
    end

    trace1  = scatter(x=5:5:100, y=out_auc[1, :], mode="markers+lines", name="OG",marker=attr(symbol=0),line=attr(dash="dot"))
    trace2  = scatter(x=5:5:100, y=out_auc[2, :], mode="markers+lines", name="OG-new",marker=attr(symbol=1))
    trace3  = scatter(x=5:5:100, y=out_auc[3, :], mode="markers+lines", name="OG'",marker=attr(symbol=2),line=attr(dash="dashdot"))
    trace4  = scatter(x=5:5:100, y=out_auc[4, :], mode="markers+lines", name="OG*",marker=attr(symbol=3),line=attr(dash="dash"))
    layout  = Layout(width=850, height=510, margin=attr(l=80, r=10, t=50, b=70),
                     xaxis=attr(title="Number of worlds", tickfont=attr(size=18),range=[range1,range2]), yaxis=attr(tickfont=attr(size=18)), font_size=20,
                     annotations=[(x=-0.15, y=.5, xref="paper", yref="paper", text="AUC", showarrow=false, textangle=-90, font=Dict(size=>21))],title=titula)
    data    = [trace1,trace3,trace4,trace2]
    a=Plot(data, layout)
    if name[1] == '.'
        savefig(a,name)
    end
end


using CSV, DataFrames
function arr_to_csv(x, outputstring)
    df = DataFrame(i = Float64[], j = Float64[], k = Float64[], x = Float64[])
    sizes = size(x)

    for k in 1:sizes[3]
        for j in 1:sizes[2]
            for i in 1:sizes[1]
                push!(df, (i, j, k, x[i,j,k]))
            end
        end
    end
    df |> CSV.write(outputstring, header = ["measure", "worlds", "repetition", "value"])
end

function fake_sims(n_worlds::Float64, n_repetition::Float64,csv_reader)
    fake_sim=Float64[]
    for row in csv_reader
        if row.worlds==n_worlds && row.repetition==n_repetition
            push!(fake_sim,row.value)
        end
    end
    return fake_sim
end

function csv_to_out_ar(file::String,first::Int64=1,final::Int64=0)
        csv_reader = CSV.File(file)
        if final == 0
            final=Int64(csv_reader[length(csv_reader)][3])
        end
        # out_ar = Array{Float64,3}(undef, 4, 20, final)
        out_ar = Array{Float64,3}(undef, 9, 20, final)
        # we use 9 dimensions because we simulated additional measures for another project.

        #
        for i in first:Int64(final)
            for n in 1:1:20
                out_ar[:,n, i] = fake_sims(Float64(n),Float64(i),csv_reader)
            end
        end

        return out_ar
    end


# to run through all csvs, first
files = readdir("./csvs")
csv_files = []
for file in files
           if occursin("full.csv",file)
               push!(csv_files,file)
           end
       end

# then we run the loop to create

for file in csv_files
    aucPlot_from_csv("./"*file[1:end-3]*"pdf","./csvs/"*file,"",[],0,100,1)
end

function csv_files_cardinality(csv_files,n,howmanytrue=0)
        card=[]
        for file in csv_files
            if occursin("-n"*string(n)*"-",file)
                push!(card,file)
            end
        end
        if howmanytrue>0
            card=only_specific_true_enough(card,howmanytrue)
        elseif howmanytrue<0
            card=only_specific_true_enough(card,n+howmanytrue)
        end
        return card
end

function csv_files_a0(csv_files,a0,howmanytrue=0)
        card=[]
        for file in csv_files
            if occursin("-a0_"*string(a0)*"conf",file)
                push!(card,file)
            end
        end
        card2=[]
        if howmanytrue>0
            push!(card2,only_specific_true_enough(card,howmanytrue))
        elseif howmanytrue<0
            push!(card2,only_specific_true_enough2(card,howmanytrue))
        end
        if howmanytrue!=0
            card=card2[1]
        end
        return card
end

function csv_files_all(csv_files,howmanytrue)
    card2=[]
    card=csv_files
    if howmanytrue>0
        push!(card2,only_specific_true_enough(csv_files,howmanytrue))
    elseif howmanytrue<0
        push!(card2,only_specific_true_enough2(csv_files,howmanytrue))
    end
    if howmanytrue!=0
        card=card2[1]
    end
    return card
end

function only_specific_true_enough(csv_files,props)
        card=[]
        for file in csv_files
            if occursin("_autogenerated_"*string(props)*"_",file)
                push!(card,file)
            end
        end
        return card
end

function only_specific_true_enough2(csv_files,minusprops)
        card=[]
        for file in csv_files
            if occursin("_autogenerated_"*string(file[6]+minusprops)*"_",file)
                push!(card,file)
            end
        end
        return card
end



function average_out_ar_from_list(csvs)
    csv_aucs=[]
    for i in csvs
        push!(csv_aucs,mean(csv_to_out_ar(i),dims=3))
    end
    for i in 2:length(csv_aucs)
        csv_aucs[1]+=csv_aucs[i]
    end

    return csv_aucs[1]/length(csv_aucs)
end

function aucPlot_from_csvs(csv_files,n,a0,style,howmanytrue=0)
    # style == 1: cardinality, 2: a0, 3: all, 4: all, true enough n
    if style==1
        files=csv_files_cardinality(csv_files,n,howmanytrue)
        if howmanytrue==0
            of=", n="*string(n)
            titula2="all_a0_n_"*string(n)
        elseif howmanytrue>0
            of=", true: "*string(howmanytrue)*" (of "*string(n)*")"
            titula2="all_a0_trueenough_"*string(howmanytrue)*"of_n_"*string(n)
        elseif howmanytrue<=-1
            of=", true: "*string(howmanytrue)*" (of "*string(n)*")"
            titula2="all_a0_trueenough_all_minus_"*string(abs(howmanytrue))*"of_n_"*string(n)
        end
        titula="average over all a0"*of
        range1=n*2
        while range1%5>0
            range1+=1
        end
    elseif style==2
        files=csv_files_a0(csv_files,a0,howmanytrue)
        titula="average over all n, a0="*string(a0)
        titula2="all_n_a0_"*string(a0)
        if howmanytrue!=0
            titula2*="_howmanytrue"*string(howmanytrue)
            titula*=", howmanytrue: "*string(howmanytrue)
        end
        range1=15
    elseif style==3
        files=csv_files
        titula="average over all n and a0"
        titula2="all_n_and_all_a0"
        range1=15
    elseif style==4
        files=csv_files_all(csv_files,howmanytrue)
        titula="average over all n and a0, true enough ="*string(howmanytrue)
        titula2="all_n_and_all_a0_"*string(howmanytrue)
        range1=15
    end
    aucPlot_from_csv("./auc-"*titula2*".pdf","",titula,files,range1,100,0)
end

csv_files2=[]
for file in csv_files
    push!(csv_files2,"./csvs/"*file)
end
# below: demo run for 4 propositions
# aucPlot_from_csvs(csv_files2,4,0.5,4,-1)
# aucPlot_from_csvs(csv_files2,4,0.5,4,0)
# aucPlot_from_csvs(csv_files2,4,0.5,4,-2)
# aucPlot_from_csvs(csv_files2,4,0.5,1,0)


# below: a way to produce aggregated plots from csv files generated earlier in the other document (note: the csvs should be in folder "csvs")
for n in 3:7
    aucPlot_from_csvs(csv_files2,n,0.5,1,0)
end
for n in 3:7
    aucPlot_from_csvs(csv_files2,n,0.5,1,-1)
end
for n in 4:7
    aucPlot_from_csvs(csv_files2,n,0.5,1,-2)
end

for a0 in [0.1,0.3,0.5,0.7,0.9]
    aucPlot_from_csvs(csv_files2,4,a0,2,0) # note the 4 is irrelevant, it looks at all a0 for all n
end

for a0 in [0.1,0.3,0.5,0.7,0.9]
    aucPlot_from_csvs(csv_files2,4,a0,2,-1)
end

for a0 in [0.1,0.3,0.5,0.7,0.9]
    aucPlot_from_csvs(csv_files2,4,a0,2,-2)
end
aucPlot_from_csvs(csv_files2,4,2.0,4,-1)