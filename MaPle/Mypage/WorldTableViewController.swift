//
//  WorldTableViewController.swift
//  MaPle
//
//  Created by juiying chiu on 2018/12/10.
//

import UIKit

class WorldTableViewController: UITableViewController {
    
    @IBOutlet weak var clickedCountryLabel: UILabel!
    
    
    @IBOutlet var visitedRatioBtns: [UIButton]!
    @IBOutlet weak var totalNumBtn: UIButton!
    @IBOutlet weak var asiaNumBtn: UIButton!
    @IBOutlet weak var northAmericaNumBtn: UIButton!
    @IBOutlet weak var europeNumBtn: UIButton!
    @IBOutlet weak var southAmericaNumBtn: UIButton!
    @IBOutlet weak var africaNumBtn: UIButton!
    @IBOutlet weak var oceaniaNumBtn: UIButton!
    
    @IBOutlet weak var oceaniaRatioBtn: UIButton!
    @IBOutlet weak var southAmericaRatioBtn: UIButton!
    @IBOutlet weak var northAmericaRatioBtn: UIButton!
    @IBOutlet weak var africaRatioBtn: UIButton!
    @IBOutlet weak var europeRatioBtn: UIButton!
    @IBOutlet weak var asiaRatioBtn: UIButton!
    @IBOutlet weak var totalRatioBtn: UIButton!
    var isButtonHidden = false
    var country = String()
    let communicator = Communicator.shared
    @IBOutlet var worldTableView: UITableView!
    @IBOutlet var numBtns: [UIButton]!
     var memberId = UserDefaults.standard.integer(forKey: "MemberIDint")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getVisitedStatic()
        tableView.reloadData()
        worldTableView.allowsSelection = false
        
    }
    
    @IBAction func ratioBtnPressed(_ sender: UIButton) {
        for button in visitedRatioBtns {
            button.isHidden = !isButtonHidden
        }
        
        for button in numBtns {
            button.isHidden = isButtonHidden
        }
        
        isButtonHidden = !isButtonHidden
    }
    
    
    func updateUI() {
        guard let countryNameString = countryName(countryCode: country) else {return}
        clickedCountryLabel.text = "被點擊的國家是：\(countryNameString)"
    }
    
    
    func countryName(countryCode: String) -> String? {
        let current = Locale(identifier: "zh_Hant_TW")
        return current.localizedString(forRegionCode: countryCode)
    }
    
    func computeRatio(value countryNum: Int, _ totalCountryNum: Int) -> String{
        let ratio = Float(countryNum) / Float(totalCountryNum)
        let str = String(format: "%.2f", ratio)
        return str
    }
    
    
    func getVisitedStatic(){
        communicator.getVisitedStatic(memberId: memberId) { (result, error) in
            if let error = error {
                print("getCountryCode error:\(error)")
                return
            }
            
            guard let result = result else {
                print("getCountryCode result is nil")
                return
            }
            let finalResult = result as! [String : Int]
            print("finalResult:\(finalResult)")
            
            
            for key in finalResult.keys {
                switch key {
                case "Visited countries":
                    guard let value = finalResult[key] else {
                        return
                    }
                    let numberInWorld = 234
                    self.totalNumBtn!.setTitle("\(value)/\(numberInWorld)", for: .normal)
                    let ratio = self.computeRatio(value: value, numberInWorld)
                    self.totalRatioBtn!.setTitle("\(ratio)%", for: .normal)
                    break
                    
                case "Asia":
                    guard let value = finalResult[key] else {
                        return
                    }
                    let numberInAsia = 51
                    self.asiaNumBtn!.setTitle("\(value)/\(numberInAsia)", for: .normal)
                    let ratio = self.computeRatio(value: value, numberInAsia)
                    self.asiaRatioBtn!.setTitle("\(ratio)%", for: .normal)
                    break
                case "Europe":
                    guard let value = finalResult[key] else {
                        return
                    }
                    let numberInEurope = 46
                    self.europeNumBtn!.setTitle("\(value)/\(numberInEurope)", for: .normal)
                    let ratio = self.computeRatio(value: value, numberInEurope)
                    self.europeRatioBtn!.setTitle("\(ratio)%", for: .normal)
                    break
                case "North America":
                    guard let value = finalResult[key] else {
                        return
                    }
                    let numberInNA = 37
                    self.northAmericaNumBtn!.setTitle("\(value)/\(numberInNA)", for: .normal)
                    let ratio = self.computeRatio(value: value, numberInNA)
                    self.northAmericaRatioBtn!.setTitle("\(ratio)%", for: .normal)
                    break
                case "South America":
                    guard let value = finalResult[key] else {
                        return
                    }
                    let numberInSA = 14
                    self.southAmericaNumBtn!.setTitle("\(value)/\(numberInSA)", for: .normal)
                    let ratio = self.computeRatio(value: value, numberInSA)
                    self.southAmericaRatioBtn!.setTitle("\(ratio)%", for: .normal)
                    break
                case "Africa":
                    guard let value = finalResult[key] else {
                        return
                    }
                    let numberInAfrica = 58
                    self.africaNumBtn!.setTitle("\(value)/\(numberInAfrica)", for: .normal)
                    let ratio = self.computeRatio(value: value, numberInAfrica)
                    self.africaRatioBtn!.setTitle("\(ratio)%", for: .normal)
                    break
                case "Oceania":
                    guard let value = finalResult[key] else {
                        return
                    }
                    let numberInOceania = 28
                    self.oceaniaNumBtn!.setTitle("\(value)/\(numberInOceania)", for: .normal)
                    let ratio = self.computeRatio(value: value, numberInOceania)
                    self.oceaniaRatioBtn!.setTitle("\(ratio)%", for: .normal)
                    break
                    
                    
                default:
                    break
                }
            }
            
        }
    }
    
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}


