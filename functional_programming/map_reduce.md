Functionals
========================================================
author: 
date: 
autosize: true


Function fundamentals
========================================================
<small>
To understand functions in R you need to internalise two important ideas:

- Functions can be broken down into three components: arguments, body, and environment.

There are exceptions to every rule, and in this case, there is a small selection of "primitive" base functions that are implemented purely in C.

- Functions are objects, just as vectors are objects.

Function fundamentals: components
========================================================

A function has three parts:

The __formals()__, the list of arguments that control how you call the function.

The __body()__, the code inside the function.

The __environment()__, the data structure that determines how the function finds the values associated with the names.</small>


Function fundamentals
========================================================

```r
f02 <- function(x, y) {
  # A comment
  x + y
}

formals(f02)
#> $x
#> $y

body(f02)
#> {
#>     x + y
#> }

environment(f02)
#> <environment: R_GlobalEnv>
```

Function fundamentals
========================================================
Like all objects in R, functions can also possess any number of additional __attributes()__. One attribute used by base R is __srcref__, short for source reference. It points to the source code used to create the function. The srcref is used for printing because, unlike __body()__, it contains code comments and other formatting.


```r
attr(f02, "srcref")
#> function(x, y) {
#>   # A comment
#>   x + y
#> }
```

Primitive functions
========================================================
There is one exception to the rule that a function has three components. Primitive functions, like sum() and [, call C code directly.


```r
sum
#> function (..., na.rm = FALSE)  .Primitive("sum")
`[`
#> .Primitive("[")
```
They have either type `builtin` or type `special`.

```r
typeof(sum)
#> [1] "builtin"
typeof(`[`)
#> [1] "special"
```

Primitive functions
========================================================

These functions exist primarily in C, not R, so their formals(), body(), and environment() are all NULL:


```r
formals(sum)
#> NULL
body(sum)
#> NULL
environment(sum)
#> NULL
```
Primitive functions are only found in the base package. While they have certain performance advantages, this benefit comes at a price: they are harder to write. For this reason, R-core generally avoids creating them unless there is no other option.

First-class functions
========================================================
Unlike in many other languages, there is no special syntax for defining and naming a function: you simply create a function object (with function) and bind it to a name with `<-`:


```r
f01 <- function(x) {
  sin(1 / x ^ 2)
}
```

<img src = "img/first-class.png" width="250px" align="centre" >

While you almost always create a function and then bind it to a name, the binding step is not compulsory. If you choose not to give a function a name, you get an anonymous function. This is useful when it's not worth the effort to figure out a name:

First-class functions
========================================================

```r
lapply(mtcars, function(x) length(unique(x)))
Filter(function(x) !is.numeric(x), mtcars)
integrate(function(x) sin(x) ^ 2, 0, pi)
```

A final option is to put functions in a list:

```r
funs <- list(
  half = function(x) x / 2,
  double = function(x) x * 2
)

funs$double(10)
#> [1] 20
```
In R, you'll often see functions called closures. This name reflects the fact that R functions capture, or enclose, their environments

Function composition
========================================================
Base R provides two ways to compose multiple function calls. For example, imagine you want to compute the population standard deviation using `sqrt()` and `mean()` as building blocks:

```r
square <- function(x) x^2
deviation <- function(x) x - mean(x)
```
You either nest the function calls:

```r
x <- runif(100)

sqrt(mean(square(deviation(x))))
#> [1] 0.274
```
Or you save the intermediate results as variables:

Function composition
========================================================

```r
out <- deviation(x)
out <- square(out)
out <- mean(out)
out <- sqrt(out)
out
#> [1] 0.274
```

Lexical scoping
========================================================
In Advanced R, __Chapter 2__, we discussed assignment, the act of binding a name to a value. Here we'll discuss scoping, the act of finding the value associated with a name.

The basic rules of scoping are quite intuitive, and you've probably already internalised them, even if you never explicitly studied them. For example, what will the following code return, 10 or 20?

```r
x <- 10
g01 <- function() {
  x <- 20
  x
}

g01()
```

Lexical scoping
========================================================
R uses lexical scoping26: it looks up the values of names based on how a function is defined, not how it is called. "Lexical" here is not the English adjective that means relating to words or a vocabulary. It's a technical CS term that tells us that the scoping rules use a parse-time, rather than a run-time structure.

R's lexical scoping follows four primary rules:

- Name masking
- Functions versus variables
- A fresh start
- Dynamic lookup


Functions versus variables
========================================================
In R, functions are ordinary objects. This means the scoping rules described above also apply to functions:


```r
g07 <- function(x) x + 1
g08 <- function() {
  g07 <- function(x) x + 100
  g07(10)
}
g08()
#> [1] 110
```


Function definitions
========================================================
In functional programming, you write functions that do the computations and then as the user, you call these functions to work for you.

You should be familiar with function definitions in R. For example, suppose you want to compute the square root of a number and want to do so using Newton's algorithm:


```r
sqrt_newton <- function(a, init, eps = 0.01){
    while(abs(init**2 - a) > eps){
        init <- 1/2 *(init + a/init)
    }
    return(init)
}
```

Function definitions
========================================================
You can then use this `function` to get the square root of a number:


```r
sqrt_newton(16, 2)
```

```
[1] 4.00122
```
We are using a while loop inside the body. The body of a function are the instructions that define the function. You can get the body of a function with `body(some_func)` of the function. In pure functional programming languages, like Haskell, you don't have loops. How can you program without loops, you may ask? In functional programming, loops are replaced by recursion. Let's rewrite our little example above with recursion:


Function definitions
========================================================


```r
sqrt_newton_recur <- function(a, init, eps = 0.01){
    if(abs(init**2 - a) < eps){
        result <- init
    } else {
        init <- 1/2 * (init + a/init)
        result <- sqrt_newton_recur(a, init, eps)
    }
    return(result)
}
```


```r
sqrt_newton_recur(16, 2)
```

```
[1] 4.00122
```

Mapping and Reducing: the base way
========================================================
`Map()` allows you to map your function to every element of a list of arguments and is easy to understand, while `Reduce()` (sometimes called `fold()` in other programming languages) reduces a list of values to a single value by successively applying a function. 
It's a bit harder to understand, but with some examples it will become clear soon enough. 

In this section we will focus on how to do things using base functions. 

In the next section we will take a look at the `purrr` package which extends R's functional programming capabilities tremendously.

Mapping with `Map()` and the `*apply()` family of functions
========================================================
Now that we have our nice function that computes square roots using Newton's algorithm, we would like to compute the square root of every element in the following list:


```r
numbers <- c(16, 25, 36, 49, 64, 81)

sqrt_newton(numbers, init = rep(1, 6), eps = rep(0.001, 6))
```

```
[1] 4.000001 5.000023 6.000253 7.001406 8.005148 9.014272
```

```r
#>Warning messages:
#>1: In while (abs(init^2 - a) > eps) { :  the condition has length > 1 and only the first element will be used
```

Mapping with `Map()` and the `*apply()` family of functions
========================================================

<small>We get these warnings because the condition (init^2 - a) > eps does not make sense for vectors. Here, R tells the user that it only uses the first element and then does the computation anyways. I would prefer if R would stop the execution and print an error message. This would force the user to have to rewrite the function to explicitly take vectors into account. And there is a very simple way of doing it, by using the function Map()</small>


```r
Map(sqrt_newton, numbers, init = 1)
## [[1]]
## [1] 4.000001
## 
## [[2]]
## [1] 5.000023
## 
## [[3]]
## [1] 6.000253
```

Mapping with `Map()` and the `*apply()` family of functions
========================================================
`Map()` applies a function to every element of a list and returns a list.

We could then write a wrapper around `Map()`:


```r
sqrt_newton_vec <- function(numbers, init, eps = 0.01){
    return(Map(sqrt_newton, numbers, init, eps))
}

sqrt_newton_vec(numbers, 1)
```
<small>As you can see, we can give a function as an argument to another function. This makes Map() a higher-order function. Higher-order functions are functions that take other functions as arguments and return either another function, or a value. This is another important concept in functional programming and encourages modularity. It makes your code easily reusable! </small>

Mapping with `Map()` and the `*apply()` family of functions
========================================================
<small>R has other higher-order functions that work like `Map()`, such as `apply()`, `lapply()`, `mapply()`, `sapply()`, `vapply()` and `tapply()`. Depending on what you want to do, you will have to use one or the other. `apply()` and `'tapply()'` are different from the other `*apply()` functions, because they work on arrays. You can apply a function on the rows or columns of an array, for example if you want a row-wise sum:</small>


```r
a <- cbind(c(1, 2, 3), c(4, 5, 6), c(7, 8, 9))
apply(a, 1, sum)
```

```
[1] 12 15 18
```

Mapping with `Map()` and the `*apply()` family of functions
========================================================
We could use `lapply()` instead of `Map()`:

```r
lapply(numbers, sqrt_newton, init = 1)
## [[1]]
## [1] 4.000001
## 
## [[2]]
## [1] 5.000023
```

or `sapply()`:


```r
sapply(numbers, sqrt_newton, init = 1)
```

```
[1] 4.000001 5.000023 6.000253 7.000000 8.000002 9.000011
```

Mapping with `Map()` and the `*apply()` family of functions
========================================================
We could rewrite `sqrt_newton_vec()` with `sapply()` which would return a better looking result (a list of numbers instead of a list of lists):


```r
sqrt_newton_vec <- function(numbers, init, eps = 0.01){
    return(sapply(numbers, sqrt_newton, init, eps))
}

sqrt_newton_vec(numbers, 1)
```

```
[1] 4.000001 5.000023 6.000253 7.000000 8.000002 9.000011
```

Mapping with `Map()` and the `*apply()` family of functions
========================================================
`mapply()` is different from these two:

```r
inits <- c(100, 20, 3212, 487, 5, 9888)
mapply(sqrt_newton, numbers, init = inits)
```

```
[1] 4.000284 5.000001 6.000003 7.000006 8.000129 9.000006
```

Mapping with `Map()` and the `*apply()` family of functions
========================================================
What happens here is that `sqrt_newton()` gets called with following arguments:

```r
sqrt_newton(numbers[1], inits[1])
```

```
[1] 4.000284
```

```r
sqrt_newton(numbers[2], inits[2])
```

```
[1] 5.000001
```

Mapping with `Map()` and the `*apply()` family of functions
========================================================
From the `Map()'s` documentation, we see that:

```r
`Map()` is wrapper to `mapply()` which does not attempt to simplify the result...
```
All this behaviour can be replicated using loops, but once you get the gist of these functions, you can write code that is shorter and easier to read and unlike in the case of recursion, without any loss in performance (but without any gains either).

Reduce()
========================================================
`Reduce()` is another very useful higher-order function, especially if you want to avoid loops to make your code easier to read. In some programming languages, `Reduce()` is called `fold()`.

The following example illustrates the power of `Reduce()` well:

```r
numbers
```

```
[1] 16 25 36 49 64 81
```

```r
Reduce(`+`, numbers, init = 0)
```

```
[1] 271
```

Reduce()
========================================================
Can you guess what happens? `Reduce()` takes a function as an argument, here the function `+1` and then does the following computation:

```r
0 + numbers[1] + numbers[2] + numbers[3]...
```

It applies the user supplied function successively but has to start with something, so we give it the argument init also. This argument is actually optional.
