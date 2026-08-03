//
//  Response.swift
//  TinyRadar
//
//  Created by Bruno Gomes Pascotto on 8/2/26.
//

struct Response: Decodable {
    let time: Int
    let states: [Flight]
}
