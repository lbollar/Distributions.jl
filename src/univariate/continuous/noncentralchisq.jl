"""
    NoncentralChisq(ν, λ)

The *noncentral chi-squared distribution* (typically written χ²) with `ν` degrees of freedom and noncentrality parameter `λ` has the probability density function

$f(x; ν, λ) = \frac{1}{2}e^{-(x + λ)/2}\frac{x}{λ}^{ν/4-1/2}I_{ν/2-1}(\sqrt{λx}) \quad x>0.$

It is the distribution of the sum of squares of `ν` independent [`Normal`](:func:`Normal`) variates with individual means $μ_i$ and

$λ = \sum_{i=1}^ν{μ_i^2}$

```julia
NoncentralChisq(ν, λ)     # Noncentral chi-squared distribution with ν degrees of freedom and noncentrality parameter λ

params(d)    # Get the parameters, i.e. (ν, λ)
```

External links

* [Noncentral chi-squared distribution on Wikipedia](https://en.wikipedia.org/wiki/Noncentral_chi-squared_distribution)
"""
immutable NoncentralChisq{T<:Real} <: ContinuousUnivariateDistribution
    ν::T
    λ::T
    function NoncentralChisq(ν::T, λ::T)
        @check_args(NoncentralChisq, ν > zero(ν))
        @check_args(NoncentralChisq, λ >= zero(λ))
    	new(ν, λ)
    end
end

NoncentralChisq{T<:Real}(ν::T, λ::T) = NoncentralChisq{T}(ν, λ)
NoncentralChisq(ν::Real, λ::Real) = NoncentralChisq(promote(ν, λ)...)
NoncentralChisq(ν::Integer, λ::Integer) = NoncentralChisq(Float64(ν), Float64(λ))

@distr_support NoncentralChisq 0.0 Inf

#### Conversions

function convert{T <: Real, S <: Real}(::Type{NoncentralChisq{T}}, ν::S, λ::S)
    NoncentralChisq(T(ν), T(λ))
end
function convert{T <: Real, S <: Real}(::Type{NoncentralChisq{T}}, d::NoncentralChisq{S})
    NoncentralChisq(T(d.ν), T(d.λ))
end

### Parameters

params(d::NoncentralChisq) = (d.ν, d.λ)
@inline partype{T<:Real}(d::NoncentralChisq{T}) = T


### Statistics

mean(d::NoncentralChisq) = d.ν + d.λ
var(d::NoncentralChisq) = 2(d.ν + 2d.λ)
skewness(d::NoncentralChisq) = 2sqrt2*(d.ν + 3d.λ)/sqrt(d.ν + 2d.λ)^3
kurtosis(d::NoncentralChisq) = 12(d.ν + 4d.λ)/(d.ν + 2d.λ)^2

function mgf(d::NoncentralChisq, t::Real)
    exp(d.λ * t/(1 - 2t))*(1 - 2t)^(-d.ν/2)
end

function cf(d::NoncentralChisq, t::Real)
    cis(d.λ * t/(1 - 2im*t))*(1 - 2im*t)^(-d.ν/2)
end


### Evaluation & Sampling

@_delegate_statsfuns NoncentralChisq nchisq ν λ

rand(d::NoncentralChisq) = StatsFuns.RFunctions.nchisqrand(d.ν, d.λ)
