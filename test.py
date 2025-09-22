from onvif import ONVIFCamera


class PythonCameraONVIF():
    def __init__(self):
        self.camera = ONVIFCamera('192.168.1.218', 80, 'admin', 'peal2024', '/home/sungwoo/workspace/PythonCamera/python-onvif-zeep/wsdl')

        media_service = self.camera.create_media_service()
        self.media_profile = media_service.GetProfiles()[0]

        # print(self.media_profile)
        
        self.ptz_service = self.camera.create_ptz_service()
        self.request = self.ptz_service.create_type('GetConfigurationOptions')
        self.request.ConfigurationToken = self.media_profile.PTZConfiguration.token
        ptz_configuration_options = self.ptz_service.GetConfigurationOptions(self.request)

        # print(ptz_configuration_options)

    def ptz_runner(self):
        request = self.ptz_service.create_type('ContinuousMove')
        request.ProfileToken = self.request.ConfigurationToken # Assuming you have a profile token
        request.Velocity.PanTilt._x = 0.0  # Pan velocity   
        request.Velocity.PanTilt._y = 0.0  # Tilt velocity
        self.ptz_service.ContinuousMove(request)

        
if __name__ == "__main__":
    pc = PythonCameraONVIF()
    pc.ptz_runner()