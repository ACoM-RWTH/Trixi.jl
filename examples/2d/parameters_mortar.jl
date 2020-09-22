# TODO: Taal refactor, rename to
# - linear_advection_mortar.jl
# - advection_mortar.jl
# or something similar?

using DiffEqCallbacks
using OrdinaryDiffEq
using Trixi

advectionvelocity = (1.0, 1.0)
# advectionvelocity = (0.2, -0.3)
equations = LinearScalarAdvectionEquation2D(advectionvelocity)

initial_conditions = initial_conditions_convergence_test

surface_flux = flux_lax_friedrichs
solver = DGSEM(3, surface_flux)

coordinates_min = (-1, -1)
coordinates_max = ( 1,  1)
refinement_patches = (
  (type="box", coordinates_min=(0.0, -1.0), coordinates_max=(1.0, 1.0)),
)
mesh = TreeMesh(coordinates_min, coordinates_max,
                initial_refinement_level=2,
                refinement_patches=refinement_patches,
                n_cells_max=10_000,)


semi = Semidiscretization(mesh, equations, initial_conditions, solver)

tspan = (0.0, 1.0)
ode = semidiscretize(semi, tspan)

# TODO: Taal implement, printing stuff (Logo etc.) at the beginning (optionally)

analysis_interval = 100
alive_callback = AliveCallback(analysis_interval=analysis_interval)
analysis_callback = AnalysisCallback(semi, analysis_interval=analysis_interval,
                                     extra_analysis_integrals=(entropy,))

stepsize_callback = StepsizeCallback(cfl=2.0)

# TODO: Taal, IO
# # save_initial_solution = false
# solution_interval = 100
# solution_variables = "primitive"
# restart_interval = 10
callbacks = CallbackSet(stepsize_callback, analysis_callback, alive_callback)


sol = solve(ode, CarpenterKennedy2N54(williamson_condition=false), dt=stepsize_callback(ode),
            save_everystep=false, callback=callbacks);
# sol = solve(ode, Tsit5(), save_everystep=false, callback=callbacks);

nothing
