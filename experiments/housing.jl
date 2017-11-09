using MultivariateStats
using PLS

const defdir = PLS.dir("datasets")

function gethousingdata(dir, filename)
    url = "https://archive.ics.uci.edu/ml/machine-learning-databases/housing/housing.data"
    mkpath(dir)
    path = download(url, "$(defdir)/$filename")
end

function loaddata(test=0.1)
    filename = "housing.data"
    file = "$(defdir)/$filename"

    isfile("$(defdir)/$filename") || gethousingdata(defdir, filename)

    data = readdlm(file)

    nfeatures = size(data)[2] - 1
    target_idx = size(data)[2]

    x = data[:, 1:nfeatures]
    y = data[:, target_idx:target_idx]
    if test == 0
        xtrn = xtst = x
        ytrn = ytst = y
    else
        r = randperm(size(x,1))          # trn/tst split
        n = round(Int, (1-test) * size(x,1))
        xtrn=x[r[1:n], :]
        ytrn=y[r[1:n], :]
        xtst=x[r[n+1:end], :]
        ytst=y[r[n+1:end], :]
    end
    (xtrn, [ytrn...], xtst, [ytst...])
end

(xtrn, ytrn, xtst, ytst) = loaddata()

model    = fit(xtrn, ytrn, nfactors = 3)
pred     = transform(model, xtst)

println("[PLS] mae error :", mean(abs.(ytst .- pred)))

# linear least squares from MultiVariateStats
sol = llsq(xtrn, ytrn)
a, b = sol[1:end-1], sol[end]
yp = xtst * a + b
println("[LLS] mae error :",mean(abs.(ytst .- yp)))
