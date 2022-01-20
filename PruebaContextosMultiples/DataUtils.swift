//
//  Utils.swift
//  PruebaContextosMultiples
//
//  Created by Otto Colomina Pardo on 20/1/17.
//  Copyright © 2017 Universidad de Alicante. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class DataUtils {
    let palabras = ["esto", "es", "una", "prueba", "de", "contextos", "múltiples"]
    func seedData() {
        let request = NSFetchRequest<Nota>(entityName: "Nota")
        let miDelegate = UIApplication.shared.delegate as! AppDelegate
        let miContexto = miDelegate.persistentContainer.viewContext
        let notas = try! miContexto.fetch(request)
        if (notas.count==0) {
            print("generando notas para la bd...")
            for _ in 1...500 {
                let nota = Nota(context: miContexto)
                nota.fecha = Date()
                nota.texto = generarTextoAlAzar(tam:50)
            }
            do {
                try miContexto.save()
                print("notas generadas")
            } catch {
                print(error)
            }
        }
        
    }
    
    func refrescarDatosDeServidor(contexto ctx : NSManagedObjectContext) -> [NSManagedObject] {
        var resultados : [NSManagedObject] = []
        //Aquí supuestamente le pediríamos datos al servidor
        //y con esos datos montaríamos un array de objetos gestionados
        for _ in 1...300 {
            usleep(10000)
            let nota = Nota(context: ctx)
            nota.fecha = Date()
            nota.texto = generarTextoAlAzar(tam:50)
            resultados.append(nota)
            print("Nota recibida: \(nota.texto!)")
        }
        do {
            try ctx.save()
        } catch {
            print(error)
        }
        
        return resultados
    }
    
    func exportarNotas(contexto ctx : NSManagedObjectContext) {
        let request = NSFetchRequest<Nota>(entityName: "Nota")
        
        let resultados = try! ctx.fetch(request)
        for nota in resultados {
            print("Exportando \(nota.texto!)")
            usleep(5000)
        }
    }
    
    private func generarTextoAlAzar(tam tamanyo : Int)->String {
        var texto = ""
        for _ in 1...tamanyo {
            let pos = Int(arc4random_uniform(UInt32(palabras.count)))
            texto = texto + " " + palabras[pos]
        }
        return texto
    }
}
