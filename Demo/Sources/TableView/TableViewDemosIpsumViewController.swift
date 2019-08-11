//
//  TableViewDemosIpsumViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/25/19.
//

import UIKit
import ListableTableView


final public class TableViewDemosIpsumViewController : UIViewController
{
    let tableView : TableView = TableView(frame: .zero)
    
    override public func loadView()
    {
        self.title = "Table View"
        
        self.view = self.tableView
        
        self.tableView.setContent(animated:false) { content in
            
            content += Section(
                header: HeaderFooter(ipsum, sizing: .thatFits(.noConstraint)),
                footer: HeaderFooter("This is a footer!", sizing: .thatFits(.noConstraint))
            ) {
                $0 += "Row 1"
                $0 += "Row 2"
                $0 += Row("Short row", sizing: .thatFits(.noConstraint))
                $0 += Row(ipsum, sizing: .thatFits(.noConstraint))
                $0 += ipsum
            }
            
            content += Section(header: HeaderFooter("Section 0.5")) { rows in
                rows += [
                    "1",
                    "2",
                    "3",
                ]
            }
            
            content += Section(header: HeaderFooter("Section 1")) { rows in
                
                rows += "Row 1"
                rows += "Row 2"
                
                rows += .init("Row 3")
                rows += .init("Row 4")
            }
            
            content += Section(header: HeaderFooter("Section 2")) { rows in
                rows += Row("Row 1")
                rows += Row("Row 2")
                rows += Row("Row 3")
            }
        }
    }
}

let ipsum = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi non luctus sem, eu consectetur ipsum. Curabitur malesuada cursus ante.

Nam sit amet imperdiet odio. Duis sed risus aliquet, finibus ex in, maximus diam. Mauris dapibus cursus rhoncus. Fusce faucibus velit at leo vestibulum, a pharetra dui interdum.

Sed pellentesque nunc ut risus ornare consequat. Nunc ut sem eget risus ultrices feugiat et in ante. Sed maximus velit sed urna venenatis, in bibendum nulla sodales.
"""
