//
//  ContentView.swift
//  InstaFilter
//
//  Created by dominator on 12/01/20.
//  Copyright © 2020 dominator. All rights reserved.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    
    @State private var image: Image?
    
    @State private var filterIntensity = 0.5
    @State private var inputImage: UIImage?
    @State private var imageToSave: UIImage?
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()

    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var showAlert = false
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    let context = CIContext()
    
    var body: some View {
        let filterBinding = Binding(
            get: {
                self.filterIntensity
        },
            set: { newValue in
                self.filterIntensity = newValue
                self.applyProcessing()
        })
        
        return NavigationView{
            VStack{
                ZStack{
                    Rectangle()
                        .fill(Color.secondary)
                    if image != nil{
                        image?
                            .resizable()
                            .scaledToFit()
                    }else{
                        Text("Tap to select image")
                            .foregroundColor(Color.white)
                            .font(.headline)
                    }
                    }
                .animation(.default)
                .onTapGesture {
                    self.showImagePicker = true
                }
                
                HStack{
                    Text("Intensity")
                    Slider(value: filterBinding)
                }.padding(.vertical)
                
                HStack{
                    Button("Change filter"){
                        self.showActionSheet = true
                    }
                    Spacer()
                    Button(action: saveImage, label: { Text("Save") })
                }
            }
            .padding()
            .navigationBarTitle("InstaFilter")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: self.$inputImage, onDismiss: self.loadImage)
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(title: Text("Select filter"), buttons: [
                    .default(Text("Crystallize")) { self.setFilter(CIFilter.crystallize()) },
                    .default(Text("Edges")) { self.setFilter(CIFilter.edges()) },
                    .default(Text("Gaussian Blur")) { self.setFilter(CIFilter.gaussianBlur()) },
                    .default(Text("Pixellate")) { self.setFilter(CIFilter.pixellate()) },
                    .default(Text("Sepia Tone")) { self.setFilter(CIFilter.sepiaTone()) },
                    .default(Text("Unsharp Mask")) { self.setFilter(CIFilter.unsharpMask()) },
                    .default(Text("Vignette")) { self.setFilter(CIFilter.vignette()) },
                    .cancel()
                ])
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func loadImage(){
        //also fixing the orientetion
        guard let inputImage = inputImage?.fixedOrientation() else {return}
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing(){
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(max(1, (filterIntensity * 200)) , forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(max(1, (filterIntensity * 200)), forKey: kCIInputScaleKey) }
        guard let outputImage = currentFilter.outputImage else {return}
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent){
            let uiimage = UIImage(cgImage: cgimg)
            imageToSave = uiimage
            image = Image(uiImage: uiimage)
        }
    }
    
    func setFilter(_ filter: CIFilter){
        self.currentFilter = filter
        loadImage()
    }
    
    func saveImage(){
        if let image = self.imageToSave{
            let saver = ImageSaver()
            saver.saveImageToLibrary(image) { result in
                switch result{
                case .success:
                    print("Image saved")
                    self.alertTitle = "Success"
                    self.alertMessage = "Filtered image have been saved to your gallery"
                    self.showAlert = true
                case .error(let error):
                    print(error)
                    self.alertTitle = "Error"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }else{
            self.alertTitle = "Error"
            self.alertMessage = "Please select image to save"
            self.showAlert = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
