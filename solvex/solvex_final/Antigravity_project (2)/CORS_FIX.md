# Fixing CORS Issues in Flutter Web Development

The error `ClientFailed to fetch` in Flutter Web is typically caused by Cross-Origin Resource Sharing (CORS) restrictions. The browser blocks the frontend (running on localhost) from accessing the backend (running on a different domain like Render).

To fix this during development, you have two main options:

### Option 1: Run Chrome with Security Disabled (Recommended for Dev)

Close all instances of Chrome and run your Flutter app with the following command:

```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

If you are using VS Code or Android Studio, you can add this flag to your launch configuration.

### Option 2: Remove the Web Renderer restriction

Sometimes, switching the renderer can help, though it's less likely to fix CORS directly:

```bash
flutter run -d chrome --web-renderer html
```

### Option 3: Backend-side Fix (Permanent)

If you have access to the backend code, you should enable CORS to allow requests from your local development environment. 

In Go (which your backend seems to use), you can use the `github.com/rs/cors` package:

```go
import "github.com/rs/cors"

// ... in your main.go or router setup
c := cors.New(cors.Options{
    AllowedOrigins: []string{"http://localhost:*"}, // Allow all localhost ports
    AllowedMethods: []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
    AllowedHeaders: []string{"Authorization", "Content-Type"},
    AllowCredentials: true,
})

handler := c.Handler(router)
http.ListenAndServe(":8080", handler)
```

---

> [!TIP]
> After applying "Option 1", refresh your browser and try logging in again. The `ClientFailed to fetch` error should disappear if the server is up.
