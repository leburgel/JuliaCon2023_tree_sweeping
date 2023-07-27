using Graphs
using NamedGraphs
using ITensors
using SparseArrayKit

function nearest_neighbors(g::AbstractGraph)
    return map(e -> src(e) => dst(e), edges(g))
end

function next_nearest_neighbors(g::AbstractGraph)
    nnn = Pair{vertextype(g), vertextype(g)}[]
    for (i, v) in enumerate(vertices(g))
        nnn_v = [neighbors(g, n) for n in neighbors(g, v)]
        nnn_v = setdiff(Base.Iterators.flatten(nnn_v), neighbors(g, v))
        nnn_v = setdiff(nnn_v, vertices(g)[1:i]) # avoid double counting
        for n in nnn_v
            push!(nnn, v => n)
        end
    end
    return nnn
end

# patch for somewhat readable finite state machine printing
function Base.show(io::IO, t::Sum{Scaled{C, Prod{Op}}}) where {C}
    t == zero(t) && return show(io, 0.0)
    length(t) == 1 && return print(io, "$(ITensors.coefficient(t[1])) $(ITensors.argument(t[1]))")
    show(io, MIME("text/plain"), t)
end

function snake_tree(g::AbstractGraph)
    @assert is_tree(g)
    snaked_vertices = reverse(post_order_dfs_vertices(g, default_root_vertex(g)))
    return snaked_vertices
end

nothing