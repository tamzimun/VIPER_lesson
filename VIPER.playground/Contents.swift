import UIKit


// MARK: - View
protocol SchoolViewOutput {
    func viewIsReady()
    func popUp()
}

protocol SchoolViewInput: class {
    func display(viewModel: SchoolDataModel)
}

class SchoolViewController: UIViewController, SchoolViewInput {
    var output: SchoolViewOutput?
    private let titleLabel = UILabel()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewIsReady()
    }
    
    func display(viewModel: SchoolDataModel) {
        titleLabel.text = viewModel.title
        
    }
    
    func backButton() {
        output?.popUp()
    }
}


// MARK: - Presenter
class SchoolPresenter: SchoolViewOutput, SchoolInteractorOutput {
    weak var view: SchoolViewInput!
    weak var moduleOutput: SchoolModuleOutput?
    var interactor: SchoolInteractorInput!
    var router: SchoolRouterInput!
    var state: SchoolContaining?
    
    func viewIsReady() {
        guard let state else { return }
        interactor.fetchSchools()
        view?.display(viewModel:SchoolViewModel(title: state.title))
    }
    
    func popUp() {
        router?.popUp()
    }
    
    func didLoadSchools(school: SchoolDataModel) {
        guard let state else { return }
        state.title = school.title
    }
}

extension SchoolPresenter: SchoolModuleInput {
    func configure(data: SchoolConfigData) {
        guard let state else { return }
        state.title = data.title
    }
}

// MARK: - State
protocol SchoolStateContaining: class {
    var title: String? { get set }
}

class SchoolState: SchoolStateContaining {
    var title: String?
}


// MARK: - SchoolModuleInput
struct SchoolConfigData {
    let title: String
}

protocol SchoolModuleInput: class {
    func configure(data: SchoolConfigData)
}


// MARK: - Entity
struct SchoolDataModel {
    var title: String
}


// MARK: - Interactor
protocol SchoolInteractorInput {
    func fetchSchools()
}
protocol SchoolInteractorOutput: class {
    func didLoadSchools(school: SchoolDataModel)
}
    
class SchoolInteractor: SchoolInteractorInput {
    weak var output: SchoolInteractorOutput!
    private var webService: WebServiceType
    
    required init(webService: WebServiceType) {
        self.webService = webService
    }

    func fetchSchools() {
        let target = SchoolTarget.getAllList
        webService.load(target: target) { [weak self] in
            switch result {
            case .success(let response):
                self?.output.didLoadSchools(school: .init(title: "School"))
                print("Success")
                self?.
            case .error:
                print("Failure")
            }
        }
    }
}


// MARK: - Router
protocol SchoolRouterInput {
    func popUp()
}

class SchoolRouter: SchoolRouterInput {
    weak var viewController: UIViewController?
    
    func popUp() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Assembly
typealias SchoolConfiguration = (SchoolModuleInput) -> Void?

class SchoolModuleAssembly {
    func assemble(_ configuration: SchoolConfiguration? = nil) -> SchoolViewController {
        let viewController = SchoolViewController()
        let router = SchoolRouter()
        let presenter = SchoolPresenter()
        presenter.view = viewController
        presenter.router = router
        router.viewCtrl = viewController
        
        let state = ChildSchoolDetailsPageState()
        presenter.state = state
        let webService = serloc.getService(WebServiceType.self)
        let interactor = SchoolInteractor(webService: webService)
        interactor.output = presenter
        presenter.interactor = interactor
        viewController.output = presenter
        configuration?(presenter)
        return viewController
    }
}

