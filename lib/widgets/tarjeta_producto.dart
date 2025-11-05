import 'package:flutter/material.dart';
import 'package:ordenes/modelos/producto.dart';
import 'package:ordenes/utils/constantes.dart';
import 'package:ordenes/widgets/carga_imagen.dart';

class TarjetaProducto extends StatelessWidget {
  final Product product;
  final VoidCallback? click;
  const TarjetaProducto({Key? key, required this.product, this.click})
    : super(key: key);

  @override
  Widget build(BuildContext context) {

    Color sombreado = Constantes.colorPrimario;
    if(product.esProductoPaquete()){
      sombreado = Constantes.colorSecundario;
    }
    if(product.esProductoPersonalizable()){
      sombreado = Constantes.colorSecundario; 
    }
    

    return Stack(
      children: [
        GestureDetector(
          onTap: product.estaHabilitado()
              ? click
              : null, // solo responde si está disponible
          child: Card(
            shadowColor: sombreado,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              leading: Hero(
                tag: 'product-image-${product.idProducto}',
                child: cargarImagen(product.imagen), 
                // child: Image.network(
                //   product.imagen,
                //   width: 60,
                //   fit: BoxFit.fill,
                // ),
              ), 
              title: Text(product.nombre),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (product.esProductoSencillo()) ? Text(
                'MXN \$${product.precioCliente.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ): Container(), 
              
              (product.disponibles > 0 && product.esProductoSencillo()) ? Text(
                'Disponibles: ${product.disponibles} aprox',
                style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
              ) : Container(),
              Text(
                '${product.descripcion}',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: product.estaHabilitado()
                    ? click
                    : null, // deshabilitado si no disponible
              ),
            ),
          ),
        ),
        // (!product.estaHabilitado()) ?  
        //   Positioned.fill(
        //     child: ClipRect(
        //       // <-- recorta todo lo que salga fuera
        //       child: Container(
        //         color: Colors.black.withAlpha(80),
        //         alignment: Alignment.center,
        //         child: Transform.rotate(
        //           angle: 0.4,
        //           child: Container(
        //             padding: const EdgeInsets.symmetric(
        //               horizontal: 12,
        //               vertical: 4,
        //             ),
        //             color: Constantes.colorSecundario,
        //             child: Text(
        //               'NO DISPONIBLE',
        //               style: TextStyle(
        //                 color: Constantes.colorPrimario,
        //                 fontWeight: FontWeight.bold,
        //                 letterSpacing: 2,
        //                 fontSize: 16,
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ) : (product.disponibles == 0) ? 
        //   Positioned.fill(
        //     child: ClipRect(
        //       // <-- recorta todo lo que salga fuera
        //       child: Container(
        //         color: Colors.black.withAlpha(80),
        //         alignment: Alignment.center,
        //         child: Transform.rotate(
        //           angle: 0.4,
        //           child: Container(
        //             padding: const EdgeInsets.symmetric(
        //               horizontal: 12,
        //               vertical: 4,
        //             ),
        //             color: Constantes.colorPrimario,
        //             child: Text(
        //               'Agotado',
        //               style: TextStyle(
        //                 color: Constantes.colorSecundario,
        //                 fontWeight: FontWeight.bold,
        //                 letterSpacing: 2,
        //                 fontSize: 16,
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ) : Container() 
      ],
    );
  }
}
