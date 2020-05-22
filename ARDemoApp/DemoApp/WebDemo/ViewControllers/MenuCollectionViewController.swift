//
//  MenuCollectionViewController.swift
//  DemoApp
//
//  Created by ChenWei on 2020/5/18.
//  Copyright © 2020 Jacob. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ModelCell"

protocol MenuCallBack: class {
    func selectEntity(_ object: VirtualModelEntity)
}

class MenuCollectionViewController: UICollectionViewController {
    let menuDatas: [VirtualModelEntity] = []

    weak var callBackDelegate: MenuCallBack?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UINib(nibName: "ModelViewCell", bundle: nil), forCellWithReuseIdentifier: "ModelCell")

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return APIManager.FileNames.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ModelViewCell else {
            fatalError("Not found ModelViewCell")
        }
        cell.modelView.image = UIImage(systemName: "circle")!
        cell.activityView.startAnimating()
        print("Before Cell \(cell.isDownload)")
        if !cell.isDownload {
            cell.getWebImage(name: APIManager.FileNames[indexPath.row])
        }
        print("After Cell \(cell.isDownload)")
        return cell
    }

    // MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let entity = APIManager.ModelDictionary[APIManager.FileNames[indexPath.row]] else {
            return
        }
        callBackDelegate?.selectEntity(entity)
        self.dismiss(animated: true, completion: nil)
    }
}
