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
