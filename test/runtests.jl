"""Test sets"""

using Test
using NLPSaUT

@testset "Ipopt optim" begin
    f_fitness = function (x::T...) where {T<:Real}
        # objective
        f = x[1]^2 - x[2]
        
        # equality constraints
        h = zeros(T, 1)
        h = x[1]^3 + x[2] - 2.4
    
        # inequality constraints
        g = zeros(T, 2)
        g[2] = -0.3x[1] + x[2] - 2   # y <= 0.3x + 2
        g[1] = x[1] + x[2] - 5      # y <= -x + 5
        
        fitness = [f; h; g]
        return fitness
    end

    # problem dimensions
    nx = 2                   # number of decision vectors
    nh = 1                   # number of equality constraints
    ng = 2                   # number of inequality constraints
    lx = -10*ones(nx,)
    ux =  10*ones(nx,)
    x0 = [-1.2, 10]

    # get model
    order = 2
    diff_f = "forward"
    model = Model(Ipopt.Optimizer)
    NLPSaUT.build_model!(model, f_fitness, nx, nh, ng, lx, ux, x0;)
    set_optimizer_attribute(model, "tol", 1e-12)
    set_optimizer_attribute(model, "print_level", 5)
    println(model)

    # run optimizer
    optimize!(model)
    xopt = value.(model[:x])

    # checks
    @assert is_solved_and_feasible(model)
end

