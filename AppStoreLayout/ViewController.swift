
import UIKit

class ViewController: UIViewController {
        
    // MARK: Section Definitions
    enum Section: Hashable {
        case promoted
        case standard(String)
        case categories
    }
    enum SupplementaryViewKind {
        static let header = "header"
        static let topLine = "topLine"
        static let bottomLine = "bottomLine"
    }
    

    @IBOutlet var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(PromotedAppCollectionViewCell.self, forCellWithReuseIdentifier: PromotedAppCollectionViewCell.reuseIdentifier)
        collectionView.register(StandardAppCollectionViewCell.self, forCellWithReuseIdentifier: StandardAppCollectionViewCell.reuseIdentifier)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)
        
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: SupplementaryViewKind.header , withReuseIdentifier: SectionHeaderView.reuseIdentifier)
        
        collectionView.register(LineView.self, forSupplementaryViewOfKind: SupplementaryViewKind.topLine , withReuseIdentifier: LineView.reuseIdentifier)
  
        collectionView.register(LineView.self, forSupplementaryViewOfKind: SupplementaryViewKind.bottomLine , withReuseIdentifier: LineView.reuseIdentifier)
        
        // MARK: Collection View Setup
        collectionView.collectionViewLayout = createLayout()
                
        configureDataSource()
    }
    
  
    func configureDataSource() {
        //MARK: - Data Source Initializing
        dataSource = .init(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            
           let section = self.sections[indexPath.section]
            switch section {
            case .promoted:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PromotedAppCollectionViewCell.reuseIdentifier, for: indexPath) as! PromotedAppCollectionViewCell
                cell.configureCell(item.app!)
                return cell
                
            case .standard:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StandardAppCollectionViewCell.reuseIdentifier, for: indexPath) as! StandardAppCollectionViewCell
                cell.configureCell(item.app!, hideBottomLine: (indexPath.row + 1).isMultiple(of: 3))
                return cell
                
            case .categories:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
                let isLastItem = collectionView.numberOfItems(inSection: indexPath.section) == indexPath.row + 1
                cell.configureCell(item.category!, hideBottomLine:  isLastItem)
                return cell
         
            }
        })
        //MARK: Supplementary view Provider
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView? in
            switch kind {
            case SupplementaryViewKind.header:
                let section = self.sections[indexPath.section]
                let sectionName: String
                switch section {
                case .promoted:
                    return nil
                case .standard(let name):
                    sectionName = name
                case .categories:
                    sectionName = "Top Categories"
                }
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: SupplementaryViewKind.header, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as! SectionHeaderView
                headerView.setTitle(sectionName)
                return headerView
                
            case SupplementaryViewKind.bottomLine, SupplementaryViewKind.topLine:
                let lineView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LineView.reuseIdentifier, for: indexPath) as! LineView
                return lineView
            default: return nil
            }
        }
        
        
        //MARK: Snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
        snapshot.appendSections([.promoted])
        snapshot.appendItems(Item.promotedApps, toSection: .promoted)
        
        let popularSection = Section.standard("Popular this week")
        let essentialSection = Section.standard("Essential picks")
        
        snapshot.appendSections([popularSection, essentialSection])
        snapshot.appendItems(Item.popularApps, toSection: popularSection)
        snapshot.appendItems(Item.essentialApps, toSection: essentialSection)
        
        snapshot.appendSections([.categories])
        snapshot.appendItems(Item.categories, toSection: .categories)
        
        sections = snapshot.sectionIdentifiers
        dataSource.apply(snapshot)
    }
    
    func createLayout() -> UICollectionViewLayout {
      
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            //MARK: header Item
            let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .estimated(44))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: SupplementaryViewKind.header, alignment: .top)
         
            //MARK: line Item
            let lineItemHeight = 1 / layoutEnvironment.traitCollection.displayScale
            let lineItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .absolute(lineItemHeight))
            
            let topLineItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: lineItemSize, elementKind: SupplementaryViewKind.topLine, alignment: .top)
            let bottomLineItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: lineItemSize, elementKind: SupplementaryViewKind.bottomLine, alignment: .bottom)
            let supplementaryItemContentSize = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
            
            headerItem.contentInsets = supplementaryItemContentSize
            topLineItem.contentInsets = supplementaryItemContentSize
            bottomLineItem.contentInsets = supplementaryItemContentSize
            
            
            let section = self.sections[sectionIndex]
            switch section {
                //MARK: promoted section
            case .promoted:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.92),
                        heightDimension: .estimated(300)),
                    subitem: item,
                    count: 1)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.boundarySupplementaryItems = [topLineItem, bottomLineItem]
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 20, trailing: 0)
                return section
                
                // MARK: standard sections
            case .standard:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3)))
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.92),
                        heightDimension: .estimated(250)),
                    subitem: item,
                    count: 3)
                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.boundarySupplementaryItems = [headerItem, bottomLineItem]
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 20, trailing: 0)
                return section
                
                //MARK: categoties section
            case .categories:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)))
                
                let availableLayoutWidth = layoutEnvironment.container.effectiveContentSize.width
                let remainingWidth = availableLayoutWidth - availableLayoutWidth * 0.92
                let itemLeadindAndTrailingInset = remainingWidth / 2 + 4
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: itemLeadindAndTrailingInset, bottom: 0, trailing: itemLeadindAndTrailingInset)
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(44)),
                    subitem: item,
                    count: 1)
             
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [headerItem]
              
                return section
      
            }
        }
        return layout
    }
}

