import Vapor
import HTTP

final class PostController: ResourceRepresentable {
    func index(request: Request) throws -> ResponseRepresentable {
        return try PostX.all().makeNode().converted(to: JSON.self)
    }

    func create(request: Request) throws -> ResponseRepresentable {
        var post = try request.post()
        try post.save()
        return post
    }

    func show(request: Request, post: PostX) throws -> ResponseRepresentable {
        return post
    }

    func delete(request: Request, post: PostX) throws -> ResponseRepresentable {
        try post.delete()
        return JSON([:])
    }

    func clear(request: Request) throws -> ResponseRepresentable {
        try PostX.query().delete()
        return JSON([])
    }

    func update(request: Request, post: PostX) throws -> ResponseRepresentable {
        let new = try request.post()
        var post = post
        post.content = new.content
        try post.save()
        return post
    }

    func replace(request: Request, post: PostX) throws -> ResponseRepresentable {
        try post.delete()
        return try create(request: request)
    }

    func makeResource() -> Resource<PostX> {
        return Resource(
            index: index,
            store: create,
            show: show,
            replace: replace,
            modify: update,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    func post() throws -> PostX {
        guard let json = json else { throw Abort.badRequest }
        return try PostX(node: json)
    }
}
