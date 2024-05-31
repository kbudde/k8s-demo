load("@ytt:data", "data")

# check if the proto is enabled
def enabled(proto):
    for app in data.values.environment.applications:
        if app.proto == proto:
            return True
        end
    end
    return False
end

# return the namespace of the application
def namespace():
    ns = data.values.myks.context.app
    if data.values.argocd.app.destination.namespace!="":
        ns = data.values.argocd.app.destination.namespace
    end
    return ns
end
