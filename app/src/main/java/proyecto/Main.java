package proyecto;

import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.javalin.Javalin;
import io.javalin.http.staticfiles.Location;
import java.io.IOException;

import org.bson.types.ObjectId;
import proyecto.clases.Usuario;
import proyecto.controllers.HomeController;
import proyecto.controllers.URLController;
import proyecto.controllers.UserController;
import proyecto.grpc.UrlServiceImpl;
import proyecto.services.UserServices;
import com.mongodb.MongoClientSettings;
import com.mongodb.MongoCredential;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoDatabase;
import com.mongodb.MongoClient;
import com.mongodb.MongoException;

//import io.github.cdimascio.dotenv.Dotenv;

public class Main {

    public static void main(String[] args) throws IOException, InterruptedException {
        // Establecer las propiedades del sistema para MongoDB
        String mongoUrl = "mongodb+srv://josearieldabas01:HL4OcEYAGqynX5Jj@josedatabase.7dkjm.mongodb.net/proyecto_final?retryWrites=true&w=majority";
        String dbName = "proyecto_final";
        System.setProperty("URL_MONGO", mongoUrl);
        System.setProperty("DB_NOMBRE", dbName);

        System.setProperty("https.protocols", "TLSv1.2");

        // Verificar la conexión a MongoDB
        try {
            com.mongodb.client.MongoClient mongoClient = MongoClients.create(mongoUrl);
            MongoDatabase database = mongoClient.getDatabase(dbName);
            // Intenta obtener una colección para verificar la conexión
            database.listCollectionNames().first();
            System.out.println("Conexión a MongoDB exitosa!");
        } catch (MongoException e) {
            System.err.println("Error de conexión con MongoDB: " + e.getMessage());
            return; // Termina la ejecución si la conexión falla
        }

        // Mostrar las variables para depuración
        System.out.println("URL MongoDB: " + System.getProperty("URL_MONGO"));
        System.out.println("Base de datos: " + System.getProperty("DB_NOMBRE"));

        // Crear el usuario admin si no existe
        if (UserServices.getInstance().findByUsername("admin") == null) {
            UserServices.getInstance().crear(new Usuario(new ObjectId(), "admin", "admin", true));
        }

        // Iniciar el servidor gRPC
        new Thread(() -> {
            try {
                Server server = ServerBuilder.forPort(50051)
                        .addService(new UrlServiceImpl())
                        .build();
                server.start();
                server.awaitTermination();
            } catch (IOException | InterruptedException e) {
                e.printStackTrace();
            }
        }).start();

        // Iniciar el servidor Javalin
        Javalin app = Javalin.create(config -> {

            // Configuración de archivos estáticos para las plantillas
            config.staticFiles.add(staticFileConfig -> {
                staticFileConfig.hostedPath = "/";
                staticFileConfig.directory = "public/templates";
                staticFileConfig.location = Location.CLASSPATH;
                staticFileConfig.precompress = false;
                staticFileConfig.aliasCheck = null;
            });

            // Configuración de archivos estáticos para la carpeta pública
            config.staticFiles.add(staticFileConfig -> {
                staticFileConfig.hostedPath = "/";
                staticFileConfig.directory = "public";
                staticFileConfig.location = Location.CLASSPATH;
                staticFileConfig.precompress = false;
                staticFileConfig.aliasCheck = null;
            });

        }).start(7000);

        // Aplicar rutas
        new HomeController(app).aplicarRutas();
        new UserController(app).aplicarRutas();
        new URLController(app).aplicarRutas();
    }
}
