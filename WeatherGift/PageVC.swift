//
//  PageVC.swift
//  WeatherGift
//
//  Created by Linda Chen on 10/17/17.
//  Copyright © 2017 Synestha. All rights reserved.
//

import UIKit

class PageVC: UIPageViewController {
    
    var currentPage = 0
    var locationsArray = ["Local City", "Chestnut Hill, MA", "New York, NY"]
    
    var pageControl: UIPageControl!
    var barButtonWidth: CGFloat = 44
    var barButtonHeight: CGFloat = 44
    var listButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        setViewControllers([createDetailVC(forPage: 0)], direction: .forward, animated: false, completion: nil)
   
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configurePageControl()
        configureListButton()
    }
    
    //Page control
    func configurePageControl() {
        let pageControlHeight = barButtonWidth
        let pageControlWidth: CGFloat = view.frame.width - (barButtonWidth * 2)
        
        pageControl = UIPageControl(frame: CGRect(x: (view.frame.width - pageControlWidth) / 2, y: view.frame.height - pageControlHeight, width: pageControlWidth, height: pageControlHeight))
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.numberOfPages = locationsArray.count
        pageControl.currentPage = currentPage
       
        view.addSubview(pageControl)
    }
    
    //Buttons
    func configureListButton() {
        let barButtonHeight = barButtonWidth
        listButton = UIButton(frame: CGRect(x: view.frame.width - barButtonWidth, y: view.frame.height - barButtonHeight, width: barButtonWidth, height: barButtonHeight))
        listButton.setBackgroundImage(UIImage(named: "listbutton"), for: .normal)
        listButton.setBackgroundImage(UIImage(named: "listbutton-highlighted"), for: .highlighted)
        listButton.addTarget(self, action: #selector(segueToListVC), for: .touchUpInside)
        
        view.addSubview(listButton)
    }
    
    //MARK:- Segues
    @objc func segueToListVC(sender: UIButton!) {
       performSegue(withIdentifier: "ToListVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToListVC" {
            let controller = segue.destination as! ListVC
            controller.locationsArray = locationsArray
            controller.currentPage = currentPage
        }
    }

    @IBAction func unwindFromListVC(sender: UIStoryboardSegue) {
        // Configure the pageControl
        pageControl.numberOfPages = locationsArray.count
        pageControl.currentPage = currentPage
        // Create the child page for the location clicked in the table view
        setViewControllers([createDetailVC(forPage: currentPage)], direction: .forward, animated: false, completion: nil)
    }
    
    //MARK:- Create view controller for UIPageViewController
    func createDetailVC(forPage page: Int) -> DetailVC {
        
        currentPage = min(max(0, page), locationsArray.count-1)
        let detailVC = storyboard!.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        
        detailVC.locationsArray = locationsArray
        detailVC.currentPage = currentPage
        
        return detailVC
    }
    
}

extension PageVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let currentViewController = viewController as? DetailVC {
            if currentViewController.currentPage < locationsArray.count-1 {
                return createDetailVC(forPage: currentViewController.currentPage + 1)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? DetailVC {
            if currentViewController.currentPage > 0 {
                return createDetailVC(forPage: currentViewController.currentPage - 1)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?[0] as? DetailVC {
            pageControl.currentPage = currentViewController.currentPage
        }
    }
    
}
