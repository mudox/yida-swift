//
//  RandomDistribution.swift
//  RandomKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-2016 Nikolai Vazquez
//  Copyright (c) 2015-2016 Marchand Eric
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// Type of random distribution.
public enum RandomDistribution<T: RandomDistribuable> {

    /// Pareto distribution: https://en.wikipedia.org/wiki/Pareto_distribution.
    case pareto(scale: T, shape: T)

    /// Weibulldistribution: https://en.wikipedia.org/wiki/Weibull_distribution.
    case weibull(scale: T, shape: T)

    /// Gaussian or normal distribution: https://en.wikipedia.org/wiki/Normal_distribution.
    case gaussian(mean: T, standardDeviation: T)

    /// Log normal distribution: https://en.wikipedia.org/wiki/Log-normal_distribution.
    case logNormal(mean: T, standardDeviation: T)

    /// Exponentiel distribution: https://en.wikipedia.org/wiki/Exponential_distribution.
    case exponential(rate: T)

    /// Gamma distribution: https://en.wikipedia.org/wiki/Gamma_distribution.
    case gamma(rate: T, shape: T)

    /// Beta disctribution: https://en.wikipedia.org/wiki/Beta_distribution.
    case beta(shape1: T, shape2: T)

    /// [Uniform distribution](https://en.wikipedia.org/wiki/Uniform_distribution).
    case uniform(closedRange: ClosedRange<T>)

    /// Gaussian distribution with 0 as mean and 1 as standard deviation
    public static var gaussianDefault: RandomDistribution<T> {
        return RandomDistribution.gaussian(mean: 0, standardDeviation: 1)
    }

}

/// A type that can generate a random value using specified `RandomDistribution`
public protocol RandomDistribuable: RandomWithinClosedRange, ExpressibleByIntegerLiteral {

    /// Adds the two values and returns the result.
    static func + (lhs: Self, rhs: Self) -> Self

    /// Subtracts the two values and returns the result.
    static func - (lhs: Self, rhs: Self) -> Self

    /// Multiplies the two values and returns the result.
    static func * (lhs: Self, rhs: Self) -> Self

    /// Divides the two values and returns the result.
    static func / (lhs: Self, rhs: Self) -> Self

    /// Divides the two values and returns the remainder.
    static func % (lhs: Self, rhs: Self) -> Self

    /// Negates the value.
    static prefix func - (x: Self) -> Self

    /// Returns `self` raised to `power`.
    func raised(to power: Self) -> Self

    /// Returns the square root of `self`.
    func squareRoot() -> Self

    /// Returns the natural log of `self`.
    func log() -> Self

    /// Returns e raised to the exponent `self`.
    func exponentOfE() -> Self

    /// The next gaussian value.
    static var nextGaussianValue: Self? { get set }

}

extension RandomDistribuable {

    /// Generate a random value from specified distribution.
    public static func random(distribution: RandomDistribution<Self>, using randomGenerator: RandomGenerator = .default) -> Self {
        switch distribution {
        case .pareto(let scale, let shape):
            return randomPareto(scale: scale, shape: shape, using: randomGenerator)
        case .weibull(let scale,let  shape):
            return randomPareto(scale: scale, shape: shape, using: randomGenerator)
        case .gaussian(let mean, let standardDeviation):
            return randomGaussian(mean: mean, standardDeviation: standardDeviation, using: randomGenerator)
        case .logNormal(let mean, let standardDeviation):
            return randomLogNormal(mean: mean, standardDeviation: standardDeviation, using: randomGenerator)
        case .exponential(let rate):
            return randomExponential(rate: rate, using: randomGenerator)
        case .gamma(let rate, let shape):
            return randomGamma(rate: rate, shape: shape, using: randomGenerator)
        case .beta(let shape1, let shape2):
            return randomBeta(shape1: shape1, shape2: shape2, using: randomGenerator)
        case .uniform(let closedRange):
            return random(within: closedRange, using: randomGenerator)
        }
    }

    /// Generate a random value from [Pareto distribution](https://en.wikipedia.org/wiki/Pareto_distribution).
    ///
    /// - parameter scale: Scale parameter of Pareto distribution. Must be > 0.
    /// - parameter shape: Shape parameter of Pareto distribution. Must be > 0.
    public static func randomPareto(scale: Self, shape: Self, using randomGenerator: RandomGenerator = .default) -> Self {
        assert(shape > 0)
        assert(scale > 0)
        let u = Self.random(within: 0...1, using: randomGenerator)
        return scale * (1 - u).raised(to: -1 / shape)
    }

    /// Generate a random value from [Weibull distribution](https://en.wikipedia.org/wiki/Weibull_distribution).
    ///
    /// - parameter scale: Scale parameter of Weibull distribution. Must be > 0.
    /// - parameter shape: Shape parameter of Weibull distribution. Must be > 0.
    public static func randomWeibull(scale: Self, shape: Self, using randomGenerator: RandomGenerator = .default) -> Self {
        assert(shape > 0)
        assert(scale > 0)
        let u = Self.random(within: 0...1, using: randomGenerator)
        return scale * -((1 - u).log()).raised(to: 1 / shape)
    }

    /// Generate a random value from gaussian or normal distribution using the
    /// [polar form](https://en.wikipedia.org/wiki/Marsaglia_polar_method) of the
    /// [Box-Muller transformation](https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform).
    ///
    /// - parameter mean: the approximately wanted mean
    /// - parameter standardDeviation: the standard deviation.
    public static func randomGaussian(mean: Self = 0, standardDeviation: Self = 1, using randomGenerator: RandomGenerator = .default) -> Self {
        if let next =  nextGaussianValue {
            Self.nextGaussianValue = nil
            return mean + next * standardDeviation // return previously computed property
        }
        // (others methods The Ratio method[50], The ziggurat algorithm)
        var x1: Self = 0
        var x2: Self = 0
        var w: Self = 0
        repeat {
            x1 = 2 * Self.random(within: 0...1, using: randomGenerator) - 1
            x2 = 2 * Self.random(within: 0...1, using: randomGenerator) - 1
            w = x1 * x1 + x2 * x2
        } while ( w >= 1 || w == 0)
        let multiplier = (-2 * w.log()/w).squareRoot()
        let y1 = x1 * multiplier
        Self.nextGaussianValue = x2 * multiplier
        return mean + y1 * standardDeviation
    }

    /// Generate a random value from [lognormal distribution](https://en.wikipedia.org/wiki/Log-normal_distribution).
    ///
    /// - parameter mean: the approximately wanted mean
    /// - parameter standardDeviation: the standard deviation.
    public static func randomLogNormal(mean: Self = 0, standardDeviation: Self = 1, using randomGenerator: RandomGenerator = .default) -> Self {
       return randomGaussian(mean: mean, standardDeviation: standardDeviation, using: randomGenerator).exponentOfE()
    }

    /// Generate a random value from [exponential distribution](https://en.wikipedia.org/wiki/Exponential_distribution).
    ///
    /// - parameter rate: Rate parameter of exponential distribution. Must be > 0.
    public static func randomExponential(rate: Self, using randomGenerator: RandomGenerator = .default) -> Self {
        assert(rate > 0)
        let u = Self.random(within: 0...1, using: randomGenerator)
        return -1 / rate * u.log()
    }

    /// Generate a random value from [gamma distribution](https://en.wikipedia.org/wiki/Gamma_distribution).
    ///
    /// - parameter rate: Rate parameter of gamma distribution. Must be > 0.
    /// - parameter shape: Shape parameter of gamma distribution. Must be > 0.
    public static func randomGamma(rate: Self, shape: Self, using randomGenerator: RandomGenerator = .default) -> Self {
        let lambda = rate / shape
        var v: Self
        var u: Self
        repeat {
            u = Self.random(within: 0...1, using: randomGenerator)
            v = Self.randomExponential(rate: lambda, using: randomGenerator)
        } while (shape - 1) * (1 - lambda * v).exponentOfE() < u

        return v
    }

    /// Generate a random value from [beta distribution](https://en.wikipedia.org/wiki/Beta_distribution).
    ///
    /// - parameter shape1: Rate parameter of beta distribution. Must be > 0.
    /// - parameter shape2: Shape parameter of beta distribution. Must be > 0.
    public static func randomBeta(shape1: Self, shape2: Self, using randomGenerator: RandomGenerator = .default) -> Self {
        let a = ((shape1 - 1) / (shape1 + shape2 - 2)).raised(to: shape1 - 1)
        let b = ((shape2 - 1) / (shape1 + shape2 - 2)).raised(to: shape2 - 1)
        let maxValue = a * b
        var u1, u2: Self
        repeat {
            u1 = Self.random(within: 0...1, using: randomGenerator)
            u2 = Self.random(within: 0...maxValue, using: randomGenerator)
        } while u2 > u1.raised(to: shape1 - 1) * u1.raised(to: shape2 - 1)
        return u1
    }
}


extension RandomDistribuable {

    /// Returns a generator for random values using `distribution`.
    public static func randomIterator(distribution: RandomDistribution<Self>,
                                      using randomGenerator: RandomGenerator = .default) -> AnyIterator<Self> {
        return AnyIterator { random(distribution: distribution, using: randomGenerator) }
    }

    /// Returns a generator for random values using `distribution` within `maxCount`.
    public static func randomIterator(maxCount count: Int,
                                      distribution: RandomDistribution<Self>,
                                      using randomGenerator: RandomGenerator = .default) -> AnyIterator<Self> {
        var n = 0
        return AnyIterator {
            defer { n += 1 }
            return n < count ? random(distribution: distribution, using: randomGenerator) : nil
        }
    }

    /// Returns a sequence of infinite random values using specified distribution.
    public static func randomSequence(distribution: RandomDistribution<Self>,
                                      using randomGenerator: RandomGenerator = .default) -> AnySequence<Self> {
        return AnySequence(randomIterator(distribution: distribution, using: randomGenerator))
    }

    /// Returns a sequence of random values using specified distribution within `maxCount`.
    public static func randomSequence(maxCount count: Int,
                                      distribution: RandomDistribution<Self>,
                                      using randomGenerator: RandomGenerator = .default) -> AnySequence<Self> {
        return AnySequence(randomIterator(maxCount: count, distribution: distribution, using: randomGenerator))
    }

}

extension Array where Element: RandomDistribuable {

    /// Construct an Array of random elements using `distribution`.
    public init(randomCount: Int, distribution: RandomDistribution<Element>, using randomGenerator: RandomGenerator = .default) {
        self.init(Element.randomSequence(maxCount: randomCount, distribution: distribution, using: randomGenerator))
    }

}

/// Protocol to generate a random probability.
public protocol BernoulliProbability: RandomWithinClosedRange, ExpressibleByIntegerLiteral, Comparable {

    /// Range of value used for bernouilli probability (usually 0...1).
    static var bernouilliRange: ClosedRange<Self> {get}

    /// Negates the value.
    static prefix func -(x: Self) -> Self
    
    /// Adds the two values and returns the result.
    static func + (lhs: Self, rhs: Self) -> Self

    /// Subtracts the two values and returns the result.
    static func - (lhs: Self, rhs: Self) -> Self

    /// Multiplies the two values and returns the result.
    static func * (lhs: Self, rhs: Self) -> Self

    /// Divides the two values and returns the result.
    static func / (lhs: Self, rhs: Self) -> Self

    /// Returns e raised to the exponent `self`.
    func exponentOfE() -> Self

}

extension BernoulliProbability {

    /// Generate a random value within the `bernouilliRange` comparable to the probability parameters of the
    /// distribution.
    public static func randomProbability(using randomGenerator: RandomGenerator = .default) -> Self {
        return Self.random(within: Self.bernouilliRange, using: randomGenerator)
    }

}

/// Type of [discrete random distribution](https://en.wikipedia.org/wiki/Probability_distribution#Discrete_probability_distribution).
public enum DiscreteRandomDistribution<T: DiscreteRandomDistribuable, P: BernoulliProbability> {

    /// [Bernoulli distribution](https://en.wikipedia.org/wiki/Bernoulli_distribution).
    case bernoulli(probability: P)

    /// [Binomial distribution](https://en.wikipedia.org/wiki/Binomial_distribution).
    case binomial(trials: Int, probability: P)

    /// [Geometric distribution](https://en.wikipedia.org/wiki/Geometric_distribution).
    case geometric(probability: P)

    /// [Poisson distribution](https://en.wikipedia.org/wiki/Poisson_distribution).
    case poisson(frequency: P)

    /// [Uniform distribution](https://en.wikipedia.org/wiki/Discrete_uniform_distribution).
    case uniform(closedRange: ClosedRange<T>)

}

/// A type that can generate a random value using specified `DiscreteRandomDistribution`.
public protocol DiscreteRandomDistribuable: Random, RandomWithinClosedRange, ExpressibleByIntegerLiteral, Equatable {

    /// The two possible values.
    static var bernoulliValues: (Self, Self) { get }

    /// Adds the two values and returns the result.
    static func + (lhs: Self, rhs: Self) -> Self

    /// Multiplies the two values and returns the result.
    static func * (lhs: Self, rhs: Self) -> Self

}

extension DiscreteRandomDistribuable {

    /// Generate a random value from specified distribution.
    public static func random<P: BernoulliProbability>(distribution: DiscreteRandomDistribution<Self, P>, using randomGenerator: RandomGenerator = .default) -> Self {
        switch(distribution) {
          case .bernoulli(let p):
            return randomBernoulli(probability: p, using: randomGenerator)
        case .binomial(let n, let p):
            return randomBinomial(trials: n, probability: p, using: randomGenerator)
        case .geometric(let p):
            return randomGeometric(probability: p, using: randomGenerator)
        case .poisson(let λ):
            return randomPoisson(frequency: λ, using: randomGenerator)
        case .uniform(let closedRange):
            return random(within: closedRange, using: randomGenerator)
        }
    }

    /// Generate a random value from bernouilli [distribution](https://en.wikipedia.org/wiki/Bernoulli_distribution).
    ///
    /// - parameter probability: probability p parameter of bernouilli distribution. Must be > 0 and < 1.
    public static func randomBernoulli<P: BernoulliProbability>(probability: P, using randomGenerator: RandomGenerator = .default)  -> Self {
        let b = Self.bernoulliValues
        let x = P.randomProbability(using: randomGenerator)
        return x < probability ? b.1 : b.0
    }

    /// Generate a random value from [binomial distribution](https://en.wikipedia.org/wiki/Binomial_distribution).
    ///
    /// - parameter trials: trials parameter of binomial distribution.
    /// - parameter probability: probability p parameter of binomial distribution. Must be > 0 and < 1.
    public static func randomBinomial<P: BernoulliProbability>(trials n: Int, probability: P, using randomGenerator: RandomGenerator = .default) -> Self {
        return (0..<n).lazy
            .map({ _ in randomBernoulli(probability: probability, using: randomGenerator) })
            .reduce(0, +)
    }

    /// Generate a random value from [geometric distribution](https://en.wikipedia.org/wiki/Geometric_distribution).
    ///
    /// - parameter probability: probability p parameter of geometric distribution. Must be > 0 and < 1.
    public static func randomGeometric<P: BernoulliProbability>(probability p: P, using randomGenerator: RandomGenerator = .default) -> Self {
        let b = Self.bernoulliValues
        var x = b.0
        while randomBernoulli(probability: p, using: randomGenerator) != b.1 {
            x = x + b.1
        }
        return x
    }

    /// Generate a random value from [poisson distribution](https://en.wikipedia.org/wiki/Poisson_distribution).
    ///
    /// - parameter λ: Frequency parameter of poisson distribution. Must be > 0 and exp(-λ)!= 0.
    public static func randomPoisson<P: BernoulliProbability>(frequency λ: P, using randomGenerator: RandomGenerator = .default) -> Self {
        var x: Self = 0
        var xD: P = 0
        let one: P = 1
        var p = (-λ).exponentOfE()
        // precondition(p != 0)
        var s = p
        let u = P.randomProbability(using: randomGenerator)
        while u > s {
            x = x + 1
            xD = xD + one
            p = p * (λ / xD)
            s = s + p
        }
        return x
    }

}

extension DiscreteRandomDistribuable {

    /// Returns a generator for random values using `distribution`.
    public static func randomIterator<P: BernoulliProbability>(distribution: DiscreteRandomDistribution<Self, P>, using randomGenerator: RandomGenerator = .default) -> AnyIterator<Self> {
        return AnyIterator { random(distribution: distribution, using: randomGenerator) }
    }

    /// Returns a generator for random values using `distribution` within `maxCount`.
    public static func randomIterator<P: BernoulliProbability>(maxCount count: Int, distribution: DiscreteRandomDistribution<Self, P>, using randomGenerator: RandomGenerator = .default) -> AnyIterator<Self> {
        var n = 0
        return AnyIterator {
            defer { n += 1 }
            return n < count ? random(distribution: distribution, using: randomGenerator) : nil
        }
    }

    /// Returns a sequence of infinite random values using specified distribution.
    public static func randomSequence<P: BernoulliProbability>(distribution: DiscreteRandomDistribution<Self, P>, using randomGenerator: RandomGenerator = .default) -> AnySequence<Self> {
        return AnySequence(randomIterator(distribution: distribution, using: randomGenerator))
    }

    /// Returns a sequence of random values using specified distribution within `maxCount`.
    public static func randomSequence<P: BernoulliProbability>(maxCount count: Int, distribution: DiscreteRandomDistribution<Self, P>, using randomGenerator: RandomGenerator = .default) -> AnySequence<Self> {
        return AnySequence(randomIterator(maxCount: count, distribution: distribution, using: randomGenerator))
    }

}

extension Array where Element: DiscreteRandomDistribuable {

    /// Construct an Array of random elements using `distribution`.
    public init<P: BernoulliProbability>(randomCount: Int, distribution: DiscreteRandomDistribution<Element, P>, using randomGenerator: RandomGenerator = .default) {
        self.init(Element.randomSequence(maxCount: randomCount, distribution: distribution, using: randomGenerator))
    }

}
