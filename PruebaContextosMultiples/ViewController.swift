//
//  ViewController.swift
//  PruebaContextosMultiples
//
//  Created by Otto Colomina Pardo on 20/1/17.
//  Copyright © 2017 Universidad de Alicante. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    @objc var frc : NSFetchedResultsController<Nota>!
    
    @IBOutlet weak var tabla: UITableView!
    
    @objc lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabla.addSubview(self.refreshControl)

        DataUtils().seedData()
        let miDelegate = UIApplication.shared.delegate as! AppDelegate
        let miContexto = miDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<Nota>(entityName:"Nota")
        let orden = NSSortDescriptor(key: "fecha", ascending: false)
        request.sortDescriptors = [orden]
        self.frc = NSFetchedResultsController<Nota>(
            fetchRequest: request,
            managedObjectContext: miContexto,
            sectionNameKeyPath: nil,
            cacheName: "ListaNotas")
        self.frc.delegate = self
        try! self.frc.performFetch()
        print("lista recuperada")
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.frc.sections!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MiCelda", for: indexPath)
        
        let nota = self.frc.object(at: indexPath)
        cell.textLabel?.text = nota.texto!
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.frc.sections![section].numberOfObjects
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tabla.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tabla.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch(type) {
        case .insert:
            self.tabla.insertSections(IndexSet(integer:sectionIndex), with: .automatic)
        case .delete:
            self.tabla.deleteSections(IndexSet(integer:sectionIndex), with: .automatic)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            self.tabla.deleteRows(at: [indexPath!], with: .automatic)
        case .insert:
            self.tabla.insertRows(at: [newIndexPath!], with:.automatic )
        default:
            print("¡operación no implementada!")
        }
    }
    
    
    
    @IBAction func botonExportarPulsado(_ sender: AnyObject) {
        
        let miDelegate = UIApplication.shared.delegate as! AppDelegate
        let miContexto = miDelegate.persistentContainer.viewContext
        
        //TO-DO: esta operación hay que hacerla en un contexto en background
        DataUtils().exportarNotas(contexto: miContexto)

        let alert = UIAlertController(title: "",
                                      message: "Se han exportado las notas",
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true)

        
    }

    @IBAction func botonBorrarTodasPulsado(_ sender: AnyObject) {
        let miDelegate = UIApplication.shared.delegate as! AppDelegate
        let miContexto = miDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<Nota>(entityName: "Nota")
        let resultados = try! miContexto.fetch(request)
        for nota in resultados {
            miContexto.delete(nota)
        }
        try! miContexto.save()
        
        print("borradas todas las notas")
    }
    
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        let miDelegate = UIApplication.shared.delegate as! AppDelegate
        let miContexto = miDelegate.persistentContainer.viewContext
        print("pidiéndole datos al servidor...")
        DataUtils().refrescarDatosDeServidor(contexto: miContexto)
        print("datos recibidos")
        refreshControl.endRefreshing()
    }

}

