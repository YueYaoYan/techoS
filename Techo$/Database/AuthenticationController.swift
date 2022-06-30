//
//  AuthenticationController.swift
//  Techo$
//
//  Created by Yue Yan on 27/4/2022.
//

import Foundation
import Firebase
import FirebaseAuth
import SwiftUI

class AuthenticationController: NSObject{
    
    var authController: Auth
    var currentUser: FirebaseAuth.User?
    var authHandle: AuthStateDidChangeListenerHandle?
    
    var authListeners = MulticastDelegate<AuthListener>()
    var deleting = false
    
    override init(){
        FirebaseApp.configure()
        authController = Auth.auth()
        
        super.init()
        
        setupAuthenticationListener()
    }
    
    func loginUser(email: String, password: String) async -> String{
        var status = ""
        if currentUser != nil{
            fatalError("Firebase Authentication Failed due to unknown error!")
        }
        do {
            try await authController.signIn(withEmail: email, password: password)
        } catch {
            status = String(describing: error.localizedDescription)
        }
        return status
    }
    
    func signoutUser() async -> String{
        var status = ""
        currentUser = nil
            do {
                try authController.signOut()
            } catch {
                status = String(describing: error.localizedDescription)
            }
        return status
    }
    
    func signupUser(email: String, password: String) async -> String{
        var status = ""
        if currentUser != nil{
            fatalError("Firebase Authentication Failed due to unknown error!")
        }
            do {
                try await authController.createUser(withEmail: email, password: password)
                
            }catch{
                status = String(describing: error.localizedDescription)
            }
        
        return status
    }
    
    func updateEmail(email: String) async -> String{
        var status = ""
        do {
            print(email)
            try await authController.currentUser?.updateEmail(to: email)
        }
        catch {
            status = String(describing: error.localizedDescription)
        }
        return status
    }
    
    func updateUsername(username: String) async -> String{
        var status = ""
        let changeRequest = authController.currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = username
        do{
            try await changeRequest?.commitChanges()
        } catch{
            status = String(describing: error)
        }
        return status
    }
    
    func updatePassword(newPassword: String) async -> String{
        var status = ""
        do {
            try await authController.currentUser?.updatePassword(to: newPassword)
        }catch {
            status = String(describing: error.localizedDescription)
        }
        return status
    }
    
    func deleteUser() async -> String{
        let user = authController.currentUser
        var status = ""
        do{
            try await user?.delete()
        }catch {
            status = String(describing: error)
        }
        return status
    }
    
    func addListener(listener: AuthListener) {
        authListeners.addDelegate(listener)
        if currentUser != nil{
            authListeners.invoke { (listener) in
                listener.onAuthenticationChange(change: .success, user: currentUser)
            }
        }else{
            listener.onAuthenticationChange(change: .update, user: currentUser)
        }
    }
    
    func removeListener(listener: AuthListener) {
        authListeners.removeDelegate(listener)
    }
    
    func setupAuthenticationListener(){
        authHandle = authController.addStateDidChangeListener{ [self] (auth, user) in
            if user != nil && currentUser == nil{
                currentUser = user
                authListeners.invoke { (listener) in
                    listener.onAuthenticationChange(change: .success, user: currentUser)
                }
            }else{
                currentUser = nil
                authListeners.invoke { (listener) in
                    listener.onAuthenticationChange(change: .fail, user: currentUser)
                }
            }
        }
    }
    
    
}
