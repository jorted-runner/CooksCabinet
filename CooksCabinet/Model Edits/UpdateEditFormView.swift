//
//  UpdateEditFormView.swift
//  CooksCabinet
//
//  Created by Danny Ellis on 2/13/25.
//
//  This SwiftUI view provides an interface for users to update or create recipes.
//  - If editing a recipe, users can modify its title, ingredients, instructions, and image.
//  - If creating a new recipe, users can take/upload an image, generate a recipe using AI, and save it.
//

import SwiftUI
import SwiftData
import PhotosUI

struct UpdateEditFormView: View {
    @Environment(\.dismiss) private var dismiss  // Handles closing the view
    @Environment(\.modelContext) private var modelContext  // Access to SwiftData
    
    @State var vm: UpdateEditFormViewModel  // ViewModel managing recipe data and state
    @State private var imagePicker = ImagePicker()  // Handles image selection from gallery
    @State private var showCamera = false  // Controls camera view visibility
    @State private var cameraError: CameraPermission.CameraError?  // Stores camera permission errors
    @State private var isGeneratingRecipe = false   // Disables button while recipe is being generated
    var body: some View {
        NavigationStack {
            Form {
                if vm.isUpDating {
                    // Editing an existing recipe
                    TextField("Title", text: $vm.title)  // Editable recipe title
                    
                    VStack {
                        if vm.data != nil {
                            // Clear image button (only shown if an image exists)
                            Button("Clear Image") {
                                vm.clearImage()
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        // Image selection buttons (camera & photo gallery)
                        HStack {
                            Button("Camera", systemImage: "camera") {
                                if let error = CameraPermission.checkPermissions() {
                                    cameraError = error
                                } else {
                                    showCamera.toggle()
                                }
                            }
                            .alert(
                                isPresented: .constant(cameraError != nil),
                                error: cameraError
                            ) { _ in
                                Button("OK") { cameraError = nil }
                            } message: { error in
                                Text(error.recoverySuggestion ?? "Try again later")
                            }
                            .sheet(isPresented: $showCamera) {
                                UIKitCamera(selectedImage: $vm.cameraImage)
                                    .ignoresSafeArea()
                            }
                            
                            // Button to pick an image from the gallery
                            PhotosPicker(selection: $imagePicker.imageSelection) {
                                Label("Photos", systemImage: "photo")
                            }
                        }
                        .foregroundStyle(.white)
                        .buttonStyle(.borderedProminent)
                        
                        // Display selected image
                        Image(uiImage: vm.image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding()
                    }
                } else {
                    // AI-powered Recipe Generator
                    Text("Recipe Generator")
                    
                    HStack {
                        Button("Camera", systemImage: "camera") {
                            if let error = CameraPermission.checkPermissions() {
                                cameraError = error
                            } else {
                                showCamera.toggle()
                            }
                        }
                        .alert(
                            isPresented: .constant(cameraError != nil),
                            error: cameraError
                        ) { _ in
                            Button("OK") { cameraError = nil }
                        } message: { error in
                            Text(error.recoverySuggestion ?? "Try again later")
                        }
                        .sheet(isPresented: $showCamera) {
                            UIKitCamera(selectedImage: $vm.cameraImage)
                                .ignoresSafeArea()
                        }
                        
                        PhotosPicker(selection: $imagePicker.imageSelection) {
                            Label("Photos", systemImage: "photo")
                        }
                    }
                    .foregroundStyle(.white)
                    .buttonStyle(.borderedProminent)
                    
                    // Display selected image
                    Image(uiImage: vm.image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                    
                    if vm.data != nil {
                        // AI-based Recipe Generation Button
                        Button("Generate Recipe") {
                            isGeneratingRecipe = true  // Disable button
                            
                            let ai = aiBrain()
                            ai.generateRecipe(
                                requestString: "Create a recipe based off of the ingredients in this image.",
                                data: vm
                            ) { response in
                                DispatchQueue.main.async {
                                    
                                    guard let response = response else {
                                        print("Failed to get a response from OpenAI.")
                                        return
                                    }
                                    
                                    // Extract JSON response from AI output
                                    guard let jsonString = ai.extractJSON(from: response),
                                          let jsonData = jsonString.data(using: .utf8) else {
                                        print("Failed to extract JSON from response")
                                        return
                                    }
                                    
                                    do {
                                        // Decode AI response into `RecipeAPIResponse`
                                        let decodedRecipe = try JSONDecoder().decode(RecipeAPIResponse.self, from: jsonData)
                                        
                                        // Update ViewModel properties
                                        vm.title = decodedRecipe.title
                                        vm.ingredients = decodedRecipe.ingredients
                                        vm.instructions = decodedRecipe.instructions
                                        vm.recipeDescription = decodedRecipe.recipeDescription
                                        
                                        // Generate an AI image for the recipe
                                        ai.generateImage(
                                            title: vm.title,
                                            description: vm.recipeDescription,
                                            ingredients: vm.ingredients
                                        ) { response in
                                            
                                            DispatchQueue.main.async {
                                                guard let response = response else {
                                                    print("Failed to get a response from OpenAI.")
                                                    return
                                                }
                                                
                                                ai.downloadImage(from: response) { image in
                                                    guard let imageData = image?.jpegData(compressionQuality: 0.8) else { return }
                                                    
                                                    DispatchQueue.main.async {
                                                        print("Saving")
                                                        vm.data = imageData
                                                        
                                                        // Create new recipe model and save it
                                                        let newRecipe = RecipeModel(
                                                            title: vm.title,
                                                            ingredients: vm.ingredients,
                                                            instructions: vm.instructions,
                                                            imageData: vm.data,
                                                            recipeDescription: vm.recipeDescription
                                                        )
                                                        
                                                        if vm.image != Constants.placeholder {
                                                            newRecipe.data = vm.image.jpegData(compressionQuality: 0.8)
                                                        } else {
                                                            newRecipe.data = nil
                                                        }
                                                        
                                                        modelContext.insert(newRecipe)
                                                        
                                                        do {
                                                            try modelContext.save()  // Save to database
                                                            print("Saved")
                                                            dismiss()
                                                        } catch {
                                                            print("Failed to save recipe: \(error)")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    } catch {
                                        print("Error decoding JSON: \(error)")
                                    }
                                }
                            }
                        }
                        .disabled(isGeneratingRecipe)
                    }
                }
            }
            .onAppear {
                imagePicker.setup(vm)
            }
            .onChange(of: vm.cameraImage) {
                if let image = vm.cameraImage {
                    vm.data = image.jpegData(compressionQuality: 0.8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // Cancel button to dismiss the form
                    Button("Cancel") {
                        dismiss()
                    }
                }
                if vm.isUpDating {
                    ToolbarItem(placement: .topBarTrailing) {
                        // Update button to save recipe changes
                        Button(
                            action: {
                                if let recipe = vm.recipe {
                                    if vm.image != Constants.placeholder {
                                        recipe.data = vm.image.jpegData(compressionQuality: 0.8)
                                    } else {
                                        recipe.data = nil
                                    }
                                    recipe.title = vm.title
                                    dismiss()
                                }
                            }
                        ) { Text("Update") }
                            .disabled(vm.isDisabled)
                    }
                }
            }
        }
    }   
}

struct RecipeAPIResponse: Codable {
    var title: String
    var ingredients: [String]
    var instructions: [String]
    var recipeDescription: String
}

#Preview {
    UpdateEditFormView(vm: UpdateEditFormViewModel())
}
