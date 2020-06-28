/*
 * Copyright (c) 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

struct NetworkConfiguration {
    struct EndpointConfiguration {
        let scheme: String
        let host: String
        let port: Int?
        let path: [String]
        let certificate: Certificate? // SSL pinning certificate, nil = no pinning
    }

    let name: String
    let api: EndpointConfiguration
    let cdn: EndpointConfiguration

    func certificate(forHost host: String) -> Certificate? {
        if api.host == host { return api.certificate }
        if cdn.host == host { return cdn.certificate }

        return nil
    }

    static let development = NetworkConfiguration(
        name: "Development",
        api: .init(
            scheme: "http",
            host: "localhost",
            port: 5004,
            path: ["v1"],
            certificate: nil
        ),
        cdn: .init(
            scheme: "http",
            host: "localhost",
            port: 5004,
            path: ["v1"],
            certificate: nil
        )
    )

    static let acceptance = NetworkConfiguration(
        name: "ACC",
        api: .init(
            scheme: "https",
            host: "api-ota.alleensamenmelden.nl",
            port: nil,
            path: ["mss-acc", "v1"],
            certificate: nil
        ),
        cdn: .init(
            scheme: "https",
            host: "mss-content-acc.azurewebsites.net",
            port: nil,
            path: ["mss-acc", "v1"],
            certificate: nil
        )
    )

    static let production = NetworkConfiguration(
        name: "Production",
        api: .init(
            scheme: "https",
            host: "notknown",
            port: nil,
            path: [],
            certificate: nil
        ),
        cdn: .init(
            scheme: "https",
            host: "notknown",
            port: nil,
            path: [],
            certificate: nil
        )
    )

    var manifestUrl: URL? {
        return self.combine(path: Endpoint.manifest, fromCdn: true)
    }

    func exposureKeySetUrl(identifier: String) -> URL? {
        return self.combine(path: Endpoint.exposureKeySet(identifier: identifier), fromCdn: true)
    }

    func riskCalculationParametersUrl(identifier: String) -> URL? {
        return self.combine(path: Endpoint.riskCalculationParameters(identifier: identifier), fromCdn: true)
    }

    func appConfigUrl(identifier: String) -> URL? {
        return self.combine(path: Endpoint.appConfig(identifier: identifier), fromCdn: true)
    }

    var registerUrl: URL? {
        return self.combine(path: Endpoint.register, fromCdn: false)
    }

    func postKeysUrl(signature: String) -> URL? {
        return self.combine(path: Endpoint.postKeys, fromCdn: false, params: ["sig": signature])
    }

    var stopKeysUrl: URL? {
        return self.combine(path: Endpoint.stopKeys, fromCdn: false)
    }

    private func combine(path: Path, fromCdn: Bool, params: [String: String] = [:]) -> URL? {
        let config = fromCdn ? cdn : api

        var urlComponents = URLComponents()
        urlComponents.scheme = config.scheme
        urlComponents.host = config.host
        urlComponents.port = config.port
        urlComponents.path = "/" + (config.path + path.components).joined(separator: "/")

        if params.count > 0 {
            urlComponents.percentEncodedQueryItems = params.compactMap { parameter in
                guard let name = parameter.key.addingPercentEncoding(withAllowedCharacters: urlQueryEncodedCharacterSet),
                    let value = parameter.value.addingPercentEncoding(withAllowedCharacters: urlQueryEncodedCharacterSet) else {
                    return nil
                }

                return URLQueryItem(name: name, value: value)
            }
        }

        return urlComponents.url
    }

    private var urlQueryEncodedCharacterSet: CharacterSet = {
        // specify characters which are allowed to be unespaced in the queryString, note the `inverted`
        let characterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
        return characterSet
    }()
}
